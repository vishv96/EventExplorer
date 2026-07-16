//
//  MockNetworkService.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//
import Foundation
internal import System

struct MockNetworkService: NetworkService {

    let urlSession: URLSession
    let baseURL: URL
    let decoder: JSONDecoder
    private let simulateError: URLError?


    init(
        urlSession: URLSession = .shared,
        baseURL: URL = URL(string: "https://api.mock")!,
        decoder: JSONDecoder = .eventDecoder,
        simulateError: URLError? = nil
    ) {
        self.urlSession = urlSession
        self.baseURL = baseURL
        self.decoder = decoder
        self.simulateError = simulateError
    }

    func request<T>(_ endpoint: EndPoint) async throws -> T where T : Decodable {
        if let simulateError {
            throw simulateError
        }
        let data = try Bundle.main.load(from:"events")
        let response = try decoder.decode(T.self, from: data)
        return response
    }

}

// MARK: - Bundle helper
extension Bundle {

    enum ResourseError: Error {
        case fileNotFound
    }

    func load(from file: String) throws -> Data {
        guard let url = self.url(forResource: file, withExtension: "json") else {
            throw ResourseError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        return data
    }

    func decode<T: Decodable>(from file: String, as type: T.Type) throws -> T {
        try JSONDecoder().decode(type, from: try load(from: file))
    }
}

// MARK: - Decoder
extension JSONDecoder {
    // Decoding strategy for Date
    static var eventDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
