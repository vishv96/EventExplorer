//
//  CacheTest.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-16.
//

import Testing
@testable import EventExplorer
import UIKit
import Foundation

struct CacheTest {

    @Test("Expired Cache should return nil")
    func testExpiredCache() async throws {
        let cache = ImageCache(timeToLive: 0.1)
        let image = try #require(UIImage(systemName: "books.vertical"))
        await cache.set(image, for: "test")

        try await Task.sleep(for: .milliseconds(500))

        let value = await cache.get(for: "test")

        #expect(value == nil)
    }

    @Test("Cache is not expired and should return value")
    func testValidCache() async throws {
        let cache = ImageCache(timeToLive: 1)
        let image = try #require(UIImage(systemName: "books.vertical"))

        await cache.set(image, for: "test")
        let value = await cache.get(for: "test")

        #expect(value != nil)
    }

    @Test("Invalid Key should return nil")
    func invalidKey() async throws {
        let cache = ImageCache(timeToLive: 1)
        let value = await cache.get(for: "invalid-key")
        #expect(value == nil)
    }
}
