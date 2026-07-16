//
//  ImageCache.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//
import Foundation
import UIKit

actor ImageCache: Cache {

    let timeToLive: TimeInterval
    internal let store: NSCache<NSString, TimeStampedValue<UIImage>> = .init()
    static let shared: ImageCache = .init(timeToLive: 60)

    init(timeToLive: TimeInterval) {
        self.timeToLive = timeToLive
    }

}
