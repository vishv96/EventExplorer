//
//  EventListViewModelTest.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-16.
//
import Testing
@testable import EventExplorer
import SwiftData
import Foundation

@MainActor
struct EventListViewModelTest {

    private let modelContext: ModelContext

    init() throws {
        let schema = Schema([Event.self, Location.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(container)
    }

    @Test("Fetching events", .serialized, arguments: [
        (MockNetworkService(), EventLisingViewModel.ViewState.contentLoaded),
        (MockNetworkService(simulateError: URLError(.notConnectedToInternet)), EventLisingViewModel.ViewState.error(.init(error: URLError(.notConnectedToInternet))))
    ])
    @MainActor
    func fetch(service: NetworkService, expectedState: EventLisingViewModel.ViewState) async {
        let viewModel: EventLisingViewModel = .init(
            repo: EventRepositoryImpl(
                service: service,
                modelContext: modelContext
            )
        )
        await viewModel.loadEvents()
        #expect(viewModel.state == expectedState)
    }

    @Test("Refreshing events", .serialized, arguments: [
        (MockNetworkService(), EventLisingViewModel.ViewState.contentLoaded),
        (MockNetworkService(simulateError: URLError(.notConnectedToInternet)), EventLisingViewModel.ViewState.error(.init(error: URLError(.notConnectedToInternet))))
    ])
    func refreshAction(service: NetworkService, expectedState: EventLisingViewModel.ViewState) async throws {
        let viewModel: EventLisingViewModel = .init(
            repo: EventRepositoryImpl(
                service: service,
                modelContext: modelContext
            )
        )
        await viewModel.refresh()
        #expect(viewModel.state == expectedState)
    }

    @MainActor
    @Test("Bookmarking event", .serialized, arguments: [
        (true, true),
        (false, false)
    ])
    func bookmark(inserted: Bool, expectedIsBookmarked: Bool) async throws {
        let event = Event(
            id: "1",
            title: "title",
            time: Date(),
            imageUrl: URL(string: "https://example.com")!,
            location: Location(name: "", address: "", latitude: 0, longitude: 0)
        )
        let viewModel: EventLisingViewModel = EventLisingViewModel(
            repo: EventRepositoryImpl(
                service: MockNetworkService(),
                modelContext: modelContext
            )
        )

        if inserted {
            modelContext.insert(event)
            try modelContext.save()
        }
        await viewModel.bookmark(event: event)
        #expect(event.isBookMarked == expectedIsBookmarked)
    }

}
