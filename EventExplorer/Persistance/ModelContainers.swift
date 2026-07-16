//
//  ModelContainers.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//


import SwiftUI
import SwiftData

extension ModelContainer {

    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Event.self,
            Location.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    static let preview: ModelContainer = {
        let schema = Schema([
            Event.self,
            Location.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

}
