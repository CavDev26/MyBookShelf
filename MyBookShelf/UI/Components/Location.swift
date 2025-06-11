//
//  Location.swift
//  TravelDiary
//
//  Created by Gianni Tumedei on 30/04/24.
//

import CoreLocation
import Foundation

@Observable
class LocationService: NSObject, CLLocationManagerDelegate {
    private(set) var isMonitoring = false
    private(set) var latitude: Double? = nil
    private(set) var longitude: Double? = nil

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocation() {
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            return
        }
        if locationManager.authorizationStatus == .denied {
            return
        }
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        isMonitoring = true
    }

    func stopLocationRequest() {
        if !isMonitoring { return }
        locationManager.stopMonitoringSignificantLocationChanges()
        isMonitoring = false
    }

    // Handle location updates
    func locationManager(
        _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        stopLocationRequest()
    }

    // Handle errors in retrieving the location
    func locationManager(
        _ manager: CLLocationManager, didFailWithError error: Error
    ) {
        print("Error when monitoring location: \(error)")
        stopLocationRequest()
    }
}
