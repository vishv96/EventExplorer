//
//  LocationDTO.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//
import Foundation

struct LocationDTO: Codable {
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double

    init(name: String, address: String, latitude: Double, longitude: Double) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }

    func toLocation() -> Location {
        return Location(name: name, address: address, latitude: latitude, longitude: longitude)
    }
}
