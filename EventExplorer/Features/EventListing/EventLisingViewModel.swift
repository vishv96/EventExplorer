//
//  EventLisingViewModel.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//
import SwiftUI

@Observable
@MainActor
final class EventLisingViewModel {

    private let repo: EventRepository
    private(set) var state: ViewState = .loading
    init(repo: EventRepository) {
        self.repo = repo
    }

    func loadEvents() async {
        do {
            state = .loading
            _ = try await repo.fetchEvents()
            state = .contentLoaded
        } catch {
            state = .error(ErrorModel(error: error))
            debugPrint(error)
        }
    }

    func refresh() async {
        await loadEvents()
    }

    func bookmark(event: Event) async {
        do {
            try await repo.toggelEventBookmark(id: event.id)
        } catch {
            state = .error(ErrorModel(error: error))
        }
    }

}

extension EventLisingViewModel {
    enum ViewState: Equatable, Hashable {
        case loading
        case error(ErrorModel)
        case contentLoaded
    }
}
