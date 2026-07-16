//
//  LocationManager.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-16.
//

import CoreLocation

protocol LocationService {
    var aithorizationStatus: CLAuthorizationStatus { get }
    var currentLocation: CLLocation? { get }
    func requestPermission()
    func distance(to coordinate: CLLocation) -> CLLocationDistance?
}

@Observable
final class LocationManager: NSObject, LocationService {

    let manager = CLLocationManager()
    private(set) var aithorizationStatus: CLAuthorizationStatus
    private(set) var currentLocation: CLLocation?

    override init() {
        self.aithorizationStatus = manager.authorizationStatus
        super.init()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func distance(to coordinate: CLLocation) -> CLLocationDistance? {
        guard let currentLocation else { return nil }
        return currentLocation.distance(from: coordinate)
    }
}


extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        aithorizationStatus = status
        switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
}

extension CLLocationDistance {
    var formattedDistance: String {
        let measurement = Measurement(value: self, unit: UnitLength.meters)
        return measurement.formatted(.measurement(width: .abbreviated, usage: .road))
    }
}
