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
    
    func handleCompletion(completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            break
        case .failure(let error):
            notifyError(error)
        }
    }
    
    private func handleResponse(_ output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
        guard let response = output.response as? HTTPURLResponse else {
            throw NetworkingError.badURLResponse(url: url)
        }
        
        switch response.statusCode {
        case 200..<300:
            return output.data
        case 400:
            throw NetworkingError.badRequest
        case 401:
            throw NetworkingError.unauthorized
        case 403:
            throw NetworkingError.forbidden
        case 404:
            throw NetworkingError.notFound
        case 500:
            throw NetworkingError.serverError
        default:
            throw NetworkingError.unknown
        }
    }
    
    private func notifyError(_ error: Error) {
        var message: String = "An unexpected error occurred. Please try again."
        
        if let networkingError = error as? NetworkingError {
            switch networkingError {
            case .badRequest, .unauthorized, .forbidden, .notFound:
                message = "There was a problem processing your request. Please check and try again."
            case .serverError:
                message = "Our servers are currently facing an issue. Please try again later."
            case .badURLResponse, .unknown, .urlError:
                break
            }
        }

        print("User Alert: \(message)")
    }
}
