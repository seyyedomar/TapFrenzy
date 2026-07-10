//
//  LocationService.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-10.
//
import Foundation
import CoreLocation

@MainActor
final class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()

    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func requestOneTimeLocation() {
        manager.requestLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        Task { @MainActor in
            currentLocation = coordinate
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silently ignoring sessions just fall back to (0, 0) if no location available.
    }
}
