//
//  EventListingView.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//
import SwiftUI
import SwiftData
import Combine

struct EventListingView: View {

    @Environment(EventLisingViewModel.self) var viewModel
    @Environment(LocationManager.self) var locationService

    @Query(filter: #Predicate<Event> { $0.isBookMarked }, sort: \Event.time)
    private var bookmarkedEvents: [Event]
    @Query(sort: \Event.time) private var events: [Event]
    @State private var error: ErrorModel?

    enum Constants {
        static let title = "Events"
        static let bookmarked = "Bookmarked"
        static let emptyState = "No events found"
        static let all = "All"
        static let errorTitle = "Error"
    }

    var body: some View {
        NavigationStack {
            switch viewModel.state {
            case .loading:
                ProgressView()
            default:
               listView()
            }
        }
        .task {
            await viewModel.loadEvents()
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onAppear {
            locationService.requestPermission()
        }
        .onChange(of: viewModel.state) { oldValue, newValue in
            if case let .error(errorInfo) = newValue {
                error = .init(title: Constants.errorTitle, description: errorInfo.description)
            }
        }
        .alert(item: $error) { error in
            Alert(title: Text(error.title), message: Text(error.description))
        }
    }

    private func listView() -> some View {
        List {
            if bookmarkedEvents.isEmpty && events.isEmpty {
                Text(Constants.emptyState)
            }
            if !bookmarkedEvents.isEmpty {
                Section(header: Text(Constants.bookmarked)) {
                    EventListView(events: bookmarkedEvents) { event in
                        bookmark(event: event)
                    }
                }
            }

            if !events.isEmpty {
                Section(header: Text(Constants.all)) {
                    EventListView(events: events) { event in
                        bookmark(event: event)
                    }
                }
            }

        }
        .navigationTitle(Text(Constants.title))
    }

    private func bookmark(event: Event) {
        Task {
            await viewModel.bookmark(event: event)
        }
    }
}

private struct EventListView: View {

    let events: [Event]
    let didBookmark: (Event) -> Void

    var body: some View {
        ForEach(events) { event in
            let detailsView = EventDetailsView(event: event) { event in
                didBookmark(event)
            }
            NavigationLink(destination: detailsView) {
                Text(event.title)
            }
        }
    }
}


#Preview {
    EventListingView()
        .environment(EventLisingViewModel(repo: EventRepositoryImpl(service: MockNetworkService(), modelContext: ModelContainer.preview.mainContext)))
}
