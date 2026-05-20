//
//  MapViewModel.swift
//  FocusCorner
//

import Foundation
import MapKit
import CoreLocation
import Observation

// MARK: - Cafe place model

struct CafePlace: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem

    var name: String { mapItem.name ?? "Cafe" }
    var coordinate: CLLocationCoordinate2D { mapItem.placemark.coordinate }
    var street: String? { mapItem.placemark.thoroughfare }
}

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
    var places: [CafePlace] = []
    var isLoading = false
    var hasUserLocation = false

    // MARK: - Non-observed coordinate (read by view after cameraUpdateID fires)

    @ObservationIgnored private(set) var centerCoordinate = MapViewModel.ankaraCoordinate

    // MARK: - Constants

    static let ankaraCoordinate = CLLocationCoordinate2D(latitude: 39.9334, longitude: 32.8597)
    static let displaySpan = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
    private static let searchSpan = MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)

    // MARK: - Private

    @ObservationIgnored private let locationManager = CLLocationManager()
    @ObservationIgnored private let bridge = LocationBridge()
    @ObservationIgnored private var searchTask: Task<Void, Never>?

    // MARK: - Init

    init() {
        setupBridge()
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

    // MARK: - Handlers

    private func handleAuthChange(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            useFallback()
        default:
            break
        }
    }

    private func centerAndSearch(location: CLLocation) {
        hasUserLocation = true
        centerCoordinate = location.coordinate
        cameraUpdateID += 1
        searchNearby(coordinate: location.coordinate)
    }

    private func useFallback() {
        hasUserLocation = false
        centerCoordinate = Self.ankaraCoordinate
        cameraUpdateID += 1
        searchNearby(coordinate: Self.ankaraCoordinate)
    }

    // MARK: - MKLocalSearch

    func searchNearby(coordinate: CLLocationCoordinate2D) {
        searchTask?.cancel()
        isLoading = true

        searchTask = Task {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "cafe coffee"
            request.resultTypes = .pointOfInterest
            request.region = MKCoordinateRegion(center: coordinate, span: Self.searchSpan)

            if let response = try? await MKLocalSearch(request: request).start() {
                guard !Task.isCancelled else { return }
                places = response.mapItems.prefix(12).map { CafePlace(mapItem: $0) }
            }
            isLoading = false
        }
    }
}
