//
//  EventCache.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//
import Foundation

actor EventCache: Cache {

    let timeToLive: TimeInterval
    internal let store: NSCache<NSString, TimeStampedValue<[EventDTO]>> = .init()
    static let shared: EventCache = .init(timeToLive: 60)
    
    init(timeToLive: TimeInterval) {
        self.timeToLive = timeToLive
    }

}
