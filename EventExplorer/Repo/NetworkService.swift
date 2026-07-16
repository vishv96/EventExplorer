//
//  EventService.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//
import Foundation

// MARK: - Endpoint
enum EndPoint {

    case events

    var path: String {
        switch self {
        case .events:
            return "events"
        }
    }

    var headers: [String: String]? {
        switch self {
        case .events:
            return nil
        }
    }

    var method: HTTPMethod { .get }
}

enum HTTPMethod: String {
    case get
    case post
}

// MARK: Service
protocol NetworkService {

    var urlSession: URLSession { get }
    var baseURL: URL { get }
    var decoder: JSONDecoder { get }

    func request<T: Decodable>(_ endpoint: EndPoint) async throws -> T
}

// MARK: -  Request
extension NetworkService {
    func request<T: Decodable>(_ endpoint: EndPoint) async throws -> T {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.allHTTPHeaderFields = endpoint.headers
        let (data, response) = try await urlSession.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return try decoder.decode(T.self, from: data)
        case 400..<500:
            throw NetworkError.client(statusCode: httpResponse.statusCode)
        case 500..<600:
            throw NetworkError.server(statusCode: httpResponse.statusCode)
        default:
            throw URLError(.badServerResponse)
        }
    }
}

// MARK: -  Error
enum NetworkError: Error {
    case client(statusCode: Int)
    case server(statusCode: Int)
}
