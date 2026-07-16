//
//  CachedImageView.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//
import SwiftUI

struct CachedImageView: View {

    let imageURL: URL
    @State private var viewModel = CachedImageViewModel(cache: .shared)

    init(imageURL: URL) {
        self.imageURL = imageURL
    }

    var body: some View {
        VStack {
            if let image = viewModel.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
            }
        }
        .animation(.easeInOut, value: viewModel.image)
        .task {
            await viewModel.load(url: imageURL)
        }
    }
}

#Preview {
    Group {
        CachedImageView(imageURL: URL(string: "https://via.placeholder.com/150")!)
    }
}
