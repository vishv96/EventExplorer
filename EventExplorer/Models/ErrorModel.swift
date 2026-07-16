//
//  ErrorModel.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-16.
//

import Foundation

struct ErrorModel: Identifiable, Equatable, Hashable {
    let title: String
    let description: String
    var id: UUID { UUID() }

    init(title: String = "Something went wrong", description: String) {
        self.title = title
        self.description = description
    }

    init(error: Error) {
        self.init(description: error.localizedDescription)
    }
}
