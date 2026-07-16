//
//  CachedImageViewModel.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//
import SwiftUI
import Foundation

@Observable
@MainActor
final class CachedImageViewModel {

    var image: Image?
    var isLoading: Bool = false
    var downloadError: Error?
    private let cache: ImageCache

    init(
        image: Image? = nil,
        isLoading: Bool = false,
        downloadError: Error? = nil,
        cache: ImageCache
    ) {
        self.image = image
        self.isLoading = isLoading
        self.downloadError = downloadError
        self.cache = cache
    }

    func load(url: URL) async {
        do {
            defer { isLoading =  false }
            isLoading = true
            let cacheKey = url.absoluteString
            if let value = await cache.get(for: cacheKey) {
                image = Image(uiImage: value)
                return
            }
            let response = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: response.0) else {
                downloadError = ImageError.coruptedImage
                return
            }
            image = Image(uiImage: uiImage)
            await cache.set(uiImage, for: cacheKey)
        } catch {
            downloadError = error
        }
    }

    enum ImageError: Error {
        case coruptedImage
    }
}
