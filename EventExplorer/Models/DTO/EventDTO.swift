//
//  EventDTO.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//
import Foundation

struct EventDTO: Codable {
    
    var id: String
    var title: String
    var time: Date
    var imageUrl: URL
    var location: LocationDTO

    func toEvent() -> Event {
        return Event(id: id, title: title, time: time, imageUrl: imageUrl, location: location.toLocation())
    }
}
