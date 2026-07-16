//
//  BGTaskManager.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-16.
//

import SwiftData
import BackgroundTasks

struct BGTaskManager {
    static private let taskIdentifier = "com.eventexplorer.refresh"
    private var frequency = Date(timeIntervalSinceNow: 60 * 60)
    let repo: EventRepository

    init(repo: EventRepository) {
        self.repo = repo
    }

    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BGTaskManager.taskIdentifier, using: nil) { task in
            handleAppRefresh(task: task as! BGProcessingTask)
        }
    }

    private func handleAppRefresh(task: BGProcessingTask) {
        scheduleBackgroundTask()
        let refreshTask = Task {
            do {
                _ = try await repo.fetchEvents()
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }
        task.expirationHandler = {
            refreshTask.cancel()
        }
    }

    func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: BGTaskManager.taskIdentifier)
        request.earliestBeginDate = frequency
        do {
            try BGTaskScheduler.shared.submit(request)
            debugPrint("Background task scheduled")
        } catch {
            debugPrint("Failed to schedule background task: \(error)")
        }
    }
}
