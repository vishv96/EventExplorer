//
//  Cache.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//

import Foundation

protocol Cache: Actor {
    associatedtype Value
    var timeToLive: TimeInterval { get }
    var store: NSCache<NSString, TimeStampedValue<Value>> { get }
}

extension Cache {
    func get(for key: String) async -> Value? {
        if let cachedItem = store.object(forKey: key as NSString) {
            if cachedItem.isPast(timeToLive: timeToLive) {
                store.removeObject(forKey: key as NSString)
                debugPrint("Cache expired for key: \(key)")
                return nil
            } else {
                debugPrint("Cache hit for key: \(key)")
                return store.object(forKey: key as NSString)?.value
            }
        }
        return nil
    }

   func set(_ value: Value, for key: String) async {
        store.setObject(TimeStampedValue(value), forKey: key as NSString)
       debugPrint("Cache set for key: \(key)")
   }
}

nonisolated final class TimeStampedValue<T> {
    let value: T
    let cachedAt: Date
    init(_ value: T, cachedAt: Date = Date()) {
        self.value = value
        self.cachedAt = cachedAt
    }

    func isPast(timeToLive: TimeInterval) -> Bool {
        cachedAt.addingTimeInterval(timeToLive) < Date()
    }
}





