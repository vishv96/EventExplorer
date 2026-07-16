//
//  EventExplorerApp.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//

import SwiftUI
import SwiftData

@main
struct EventExplorerApp: App {

    let bgTaskManager: BGTaskManager

    init () {
        bgTaskManager = BGTaskManager(
            repo: EventRepositoryImpl(
                service: MockNetworkService(),
                modelContext: ModelContainer.sharedModelContainer.mainContext
            )
        )
        bgTaskManager.registerBackgroundTask()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    bgTaskManager.scheduleBackgroundTask()
                }
        }
        .modelContainer(.sharedModelContainer)
    }
}


