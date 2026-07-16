//
//  ContentView.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @State var viewModel: EventLisingViewModel = .init(
        repo: EventRepositoryImpl(
            service: MockNetworkService(),
            modelContext: ModelContainer.sharedModelContainer.mainContext
        )
    )
    @State var locationService = LocationManager()

    var body: some View {
        EventListingView()
            .environment(viewModel)
            .environment(locationService)
    }
}
