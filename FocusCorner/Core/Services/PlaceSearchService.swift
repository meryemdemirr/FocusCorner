//
//  PlaceSearchService.swift
//  FocusCorner
//

import CoreLocation
import Foundation
import MapKit
import Observation

struct PlaceSearchSuggestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String

    var displayText: String {
        subtitle.isEmpty ? title : "\(title), \(subtitle)"
    }
}

struct PlaceSearchResult: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem

    var name: String { mapItem.name ?? "Place" }
    var coordinate: CLLocationCoordinate2D { mapItem.placemark.coordinate }
    var street: String? { mapItem.placemark.thoroughfare }
    var city: String? { mapItem.placemark.locality ?? mapItem.placemark.administrativeArea }
    var subtitle: String {
        [street, city].compactMap { $0 }.joined(separator: ", ")
    }
}

private final class SearchCompleterBridge: NSObject, MKLocalSearchCompleterDelegate {
    var onResults: ([MKLocalSearchCompletion]) -> Void = { _ in }
    var onError: () -> Void = {}

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        onResults(completer.results)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        onError()
    }
}

@MainActor
@Observable
final class PlaceSearchService {
    static let turkeyCenter = CLLocationCoordinate2D(latitude: 39.0, longitude: 35.0)
    static let turkeySpan = MKCoordinateSpan(latitudeDelta: 18.0, longitudeDelta: 22.0)
    static let defaultMapSpan = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
    static let nearbySearchSpan = MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)

    var query = ""
    var suggestions: [PlaceSearchSuggestion] = []
    var results: [PlaceSearchResult] = []
    var isSearching = false

    @ObservationIgnored var onSuggestionsChanged: ([PlaceSearchSuggestion]) -> Void = { _ in }
    @ObservationIgnored var onResultsChanged: ([PlaceSearchResult]) -> Void = { _ in }
    @ObservationIgnored private let completer = MKLocalSearchCompleter()
    @ObservationIgnored private let bridge = SearchCompleterBridge()
    @ObservationIgnored private var searchTask: Task<Void, Never>?

    init() {
        bridge.onResults = { [weak self] completions in
            Task { @MainActor in
                let suggestions = completions.prefix(8).map {
                    PlaceSearchSuggestion(title: $0.title, subtitle: $0.subtitle)
                }
                self?.suggestions = suggestions
                self?.onSuggestionsChanged(suggestions)
            }
        }
        bridge.onError = { [weak self] in
            Task { @MainActor in
                self?.suggestions = []
                self?.onSuggestionsChanged([])
            }
        }
        completer.delegate = bridge
        completer.region = MKCoordinateRegion(center: Self.turkeyCenter, span: Self.turkeySpan)
        completer.resultTypes = [.address, .pointOfInterest, .query]
    }

    func updateQuery(_ text: String) {
        query = text
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedText.count >= 2 else {
            completer.queryFragment = ""
            suggestions = []
            results = []
            onSuggestionsChanged([])
            onResultsChanged([])
            return
        }

        completer.queryFragment = trimmedText
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            await self?.search(text: trimmedText)
        }
    }

    func select(_ suggestion: PlaceSearchSuggestion) async -> PlaceSearchResult? {
        query = suggestion.title
        suggestions = []
        return await search(text: suggestion.displayText).first
    }

    @discardableResult
    func search(text: String, near coordinate: CLLocationCoordinate2D? = nil) async -> [PlaceSearchResult] {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return [] }

        isSearching = true
        defer { isSearching = false }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmedText
        request.resultTypes = coordinate == nil ? [.address, .pointOfInterest] : .pointOfInterest
        request.region = MKCoordinateRegion(
            center: coordinate ?? Self.turkeyCenter,
            span: coordinate == nil ? Self.turkeySpan : Self.nearbySearchSpan
        )

        guard let response = try? await MKLocalSearch(request: request).start() else {
            results = []
            return []
        }

        let foundResults = response.mapItems.prefix(20).map { PlaceSearchResult(mapItem: $0) }
        results = foundResults
        onResultsChanged(foundResults)
        return foundResults
    }

    @discardableResult
    func searchNearbyCafes(near coordinate: CLLocationCoordinate2D) async -> [PlaceSearchResult] {
        await search(text: "cafe coffee coworking workspace", near: coordinate)
    }
}
