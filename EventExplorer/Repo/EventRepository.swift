//
//  EventRepository.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//

import SwiftData
import Foundation

@MainActor
protocol EventRepository {
    func fetchEvents() async throws -> [Event]
    func toggelEventBookmark(id: String) async throws
}

@MainActor
struct EventRepositoryImpl: EventRepository {

    private let service: NetworkService
    private let modelContext: ModelContext
    private let eventCache: EventCache

    init(service: NetworkService, modelContext: ModelContext, eventCache: EventCache = EventCache.shared) {
        self.service = service
        self.modelContext = modelContext
        self.eventCache = eventCache
    }

    func fetchEvents() async throws -> [Event] {
        // Checking if cache is available for the key/path
        if let eventsDTO: [EventDTO] = await eventCache.get(for: EndPoint.events.path) {
            return eventsDTO.map { $0.toEvent() }
        }

        let resultDTO: ResponseDTO = try await service.request(.events)
        // Caching the event response to cache
        await eventCache.set(resultDTO.events, for: EndPoint.events.path)

        let events: [Event] = resultDTO.events.map { $0.toEvent() }
        try persist(events)
        return events
    }

    private func persist(_ events: [Event]) throws {
        for event in events {
            let eventId = event.id
            let descriptor = FetchDescriptor<Event>(
                predicate: #Predicate { $0.id == eventId }
            )
            if let eventObject: Event = try modelContext.fetch(descriptor).first {
                eventObject.title = event.title
                eventObject.time = event.time
                eventObject.imageUrl = event.imageUrl
                eventObject.location = event.location
            } else {
                modelContext.insert(event)
            }
        }
        try modelContext.save()
    }

    func toggelEventBookmark(id: String) async throws {
        let descriptor = FetchDescriptor<Event>(
            predicate: #Predicate { $0.id == id }
        )
        if let event: Event = try modelContext.fetch(descriptor).first {
            event.isBookMarked.toggle()
            try modelContext.save()
        }
    }
}
