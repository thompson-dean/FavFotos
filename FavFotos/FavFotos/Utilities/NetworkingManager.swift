//
//  NetworkingManager.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/05.
//

import Foundation
import Combine

protocol NetworkingProtocol {
    func download(url: URL) -> AnyPublisher<Data, Error>
}

class NetworkingManager: NetworkingProtocol {
    
    private var headers: [String: String]
    
    init(headers: [String: String] = ["Authorization": Constants.apiKey]) {
        self.headers = headers
    }
    
    func download(url: URL) -> AnyPublisher<Data, Error> {
        var request = URLRequest(url: url)
        
        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { NetworkingError.urlError($0) }
            .tryMap { try self.handleResponse($0, url: url) }
            .retry(3)
            .eraseToAnyPublisher()
    }
    
    private func handleResponse(_ output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
        guard let response = output.response as? HTTPURLResponse else {
            throw NetworkingError.clientError(message: "Bad URL response.")
        }
        
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
