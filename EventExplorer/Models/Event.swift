//
//  Event.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//
import Foundation
import SwiftData

@Model
final class Event {

    @Attribute(.unique) var id: String
    var title: String
    var time: Date
    var imageUrl: URL

    @Relationship(deleteRule: .cascade)
    var location: Location

    var isBookMarked: Bool = false

    init(id: String, title: String, time: Date, imageUrl: URL, location: Location) {
        self.id = id
        self.title = title
        self.time = time
        self.imageUrl = imageUrl
        self.location = location
    }
}
