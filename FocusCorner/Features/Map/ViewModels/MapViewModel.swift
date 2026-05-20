//
//  MapViewModel.swift
//  FocusCorner
//

import Foundation
import MapKit
import CoreLocation
import Observation

// MARK: - CLLocationManager bridge
// NSObject subclass required by CLLocationManagerDelegate;
// kept separate so MapViewModel can stay @Observable.

private final class LocationBridge: NSObject, CLLocationManagerDelegate {
    var onAuthChange: (CLAuthorizationStatus) -> Void = { _ in }
    var onLocations: ([CLLocation]) -> Void = { _ in }
    var onError: () -> Void = {}

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuthChange(manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        onLocations(locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onError()
    }
}

// MARK: - ViewModel

@Observable
@MainActor
final class MapViewModel {

    // MARK: - Observable state

    // Incrementing this triggers the view to read `centerCoordinate` and update its camera.
    private(set) var cameraUpdateID: Int = 0
    var places: [PlaceSearchResult] = []
    var selectedPlace: PlaceSearchResult?
    var isLoading = false
    var hasUserLocation = false
    var locationStatusMessage = "Location helps Focus Corner find real nearby cafes and work-friendly places."
    var searchText = ""
    var searchSuggestions: [PlaceSearchSuggestion] = []
    var isSearchFocused = false

    // MARK: - Non-observed coordinate (read by view after cameraUpdateID fires)

    @ObservationIgnored private(set) var centerCoordinate = MapViewModel.ankaraCoordinate
    @ObservationIgnored private var userCoordinate: CLLocationCoordinate2D?

    // MARK: - Constants

    static let ankaraCoordinate = CLLocationCoordinate2D(latitude: 39.9334, longitude: 32.8597)
    // Tighter zoom so individual cafe pins are clearly visible (≈1.2 km view)
    static let displaySpan = MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)

    // MARK: - Private

    @ObservationIgnored private let locationManager = CLLocationManager()
    @ObservationIgnored private let bridge = LocationBridge()
    @ObservationIgnored private let searchService = PlaceSearchService()
    @ObservationIgnored private var searchTask: Task<Void, Never>?

    // MARK: - Init

    init() {
        setupBridge()
        setupSearchService()
        locationManager.delegate = bridge
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    // MARK: - Public entry point

    func startLocationFlow() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            useFallback()
        @unknown default:
            useFallback()
        }
    }

    func requestLocationAgain() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse
               || locationManager.authorizationStatus == .authorizedAlways else {
            useFallback()
            return
        }
        locationManager.requestLocation()
    }

    func selectMapPlace(_ place: PlaceSearchResult) {
        selectedPlace = place
    }

    func distanceText(for place: PlaceSearchResult) -> String {
        guard let userCoordinate else { return "Distance unavailable" }
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let placeLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        let kilometers = userLocation.distance(from: placeLocation) / 1_000

        if kilometers < 1 {
            return "\(Int(kilometers * 1_000)) m away"
        }
        return String(format: "%.1f km away", kilometers)
    }

    func updateSearchText(_ text: String) {
        searchText = text
        searchService.updateQuery(text)

        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(120))
            guard !Task.isCancelled else { return }
            await self?.syncSearchState()
        }
    }

    func selectSuggestion(_ suggestion: PlaceSearchSuggestion) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            isLoading = true
            defer { isLoading = false }

            guard let result = await searchService.select(suggestion) else {
                await syncSearchState()
                return
            }

            selectPlace(result)
            await loadNearbyCafes(near: result.coordinate)
            await syncSearchState()
        }
    }

    func submitSearch() {
        let text = searchText
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            isLoading = true
            defer { isLoading = false }

            let results = await searchService.search(text: text)
            if let result = results.first {
                selectPlace(result)
                await loadNearbyCafes(near: result.coordinate)
            }
            await syncSearchState()
        }
    }

    // MARK: - Bridge setup

    private func setupBridge() {
        bridge.onAuthChange = { [weak self] status in
            self?.handleAuthChange(status)
        }
        bridge.onLocations = { [weak self] locations in
            guard let location = locations.last else { return }
            self?.centerAndSearch(location: location)
        }
        bridge.onError = { [weak self] in
            self?.useFallback()
        }
    }

    private func setupSearchService() {
        searchService.onSuggestionsChanged = { [weak self] suggestions in
            self?.searchSuggestions = suggestions
        }
        searchService.onResultsChanged = { [weak self] results in
            guard !results.isEmpty else { return }
            self?.places = results
        }
    }

    // MARK: - Handlers

    private func handleAuthChange(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationStatusMessage = "Showing real cafes near your current location."
            locationManager.requestLocation()
        case .denied, .restricted:
            locationStatusMessage = "Location is off. Showing real cafes around Ankara instead."
            useFallback()
        default:
            break
        }
    }

    private func centerAndSearch(location: CLLocation) {
        hasUserLocation = true
        userCoordinate = location.coordinate
        locationStatusMessage = "Showing real cafes near your current location."
        centerCoordinate = location.coordinate
        cameraUpdateID += 1
        searchNearby(coordinate: location.coordinate)
    }

    private func useFallback() {
        hasUserLocation = false
        userCoordinate = nil
        locationStatusMessage = "Location is off. Showing real cafes around Ankara instead."
        centerCoordinate = Self.ankaraCoordinate
        cameraUpdateID += 1
        searchNearby(coordinate: Self.ankaraCoordinate)
    }

    private func selectPlace(_ place: PlaceSearchResult) {
        selectedPlace = place
        searchText = place.name
        searchSuggestions = []
        centerCoordinate = place.coordinate
        cameraUpdateID += 1
    }

    private func syncSearchState() async {
        searchSuggestions = searchService.suggestions
        if !searchService.results.isEmpty {
            places = searchService.results
        }
    }

    private func loadNearbyCafes(near coordinate: CLLocationCoordinate2D) async {
        let results = await searchService.searchNearbyCafes(near: coordinate)
        places = results
    }

    // MARK: - MKLocalSearch

    func searchNearby(coordinate: CLLocationCoordinate2D) {
        searchTask?.cancel()
        isLoading = true

        searchTask = Task { [weak self] in
            guard let self else { return }
            let results = await searchService.searchNearbyCafes(near: coordinate)
            guard !Task.isCancelled else { return }
            places = results
            isLoading = false
        }
    }
}
