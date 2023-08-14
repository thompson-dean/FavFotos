//
//  NetworkingManager.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/05.
//

import Foundation
import Combine

/// Protocol defining the networking requirements.
protocol NetworkingProtocol {
    /// Downloads data from the provided URL.
    /// - Parameter url: The target URL from which to download.
    func download(url: URL) -> AnyPublisher<Data, Error>
}

class NetworkingManager: NetworkingProtocol {
    
    /// Headers to be used in the network request.
    private var headers: [String: String]
    
    /// Initializes the `NetworkingManager`.
    /// - Parameter headers: A dictionary of HTTP headers. By default, it sets the "Authorization" header.
    init(headers: [String: String] = ["Authorization": Constants.apiKey]) {
        self.headers = headers
    }
    
    /// Downloads data from the provided URL and handles potential errors.
    /// - Parameter url: The target URL from which to download.
    func download(url: URL) -> AnyPublisher<Data, Error> {
        var request = URLRequest(url: url)
        
        // Setting headers to the request.
        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Executing the request and handling potential errors.
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { NetworkingError.urlError($0) }
            .tryMap { try self.handleResponse($0, url: url) }
            .retry(3)
            .eraseToAnyPublisher()
    }
    
    /// Handles the response received from the executed request.
    /// - Parameters:
    ///   - output: The result from the data task publisher.
    ///   - url: The target URL from which the data was downloaded.
    private func handleResponse(_ output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
        guard let response = output.response as? HTTPURLResponse else {
            throw NetworkingError.clientError(message: "Bad URL response.")
        }
        
        // Validating HTTP response codes.
        switch response.statusCode {
        case 200..<300:
            return output.data
        case 400..<500:
            throw NetworkingError.clientError(message: "Client error with code: \(response.statusCode).")
        case 500..<600:
            throw NetworkingError.serverError(message: "Server error with code: \(response.statusCode).")
        default:
            throw NetworkingError.unknown
        }
    }
}
