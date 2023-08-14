//
//  PhotoDataService.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/05.
//

import Foundation
import Combine

/// Protocol defining methods to interact with the PhotoDataService.
protocol PhotoDataServiceProtocol {
    func getPhotos(page: Int) -> AnyPublisher<PexelsResponse, Error>
    func searchPhotos(searchTerm: String, page: Int) -> AnyPublisher<PexelsResponse, Error>
    func fetchImage(_ urlString: String) -> AnyPublisher<Data, Error>
}

class PhotoDataService: PhotoDataServiceProtocol {
    
    /// Networking manager instance to execute requests.
    private let networkingManager: NetworkingProtocol
    
    /// Initializes the `PhotoDataService`.
    /// - Parameter networkingManager: An instance that conforms to `NetworkingProtocol`. By default, it uses `NetworkingManager`.
    init(networkingManager: NetworkingProtocol = NetworkingManager()) {
        self.networkingManager = networkingManager
    }
    
    /// Fetches photos for a given page.
    func getPhotos(page: Int = 1) -> AnyPublisher<PexelsResponse, Error> {
        let parameters: [String: String] = [
            "page": "\(page)",
            "per_page": "\(Constants.perPage)"
        ]
        
        switch buildURL(for: Constants.curatedAPI, with: parameters) {
        case .success(let url):
            return fetchPexelsResponse(from: url)
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    /// Searches photos based on the search term and page.
    func searchPhotos(searchTerm: String, page: Int = 1) -> AnyPublisher<PexelsResponse, Error> {
        let parameters: [String: String] = [
            "query": searchTerm,
            "page": "\(page)",
            "per_page": "\(Constants.perPage)"
        ]
        
        switch buildURL(for: Constants.searchAPI, with: parameters) {
        case .success(let url):
            return fetchPexelsResponse(from: url)
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    /// Fetches a `PexelsResponse` from the provided URL.
    private func fetchPexelsResponse(from url: URL) -> AnyPublisher<PexelsResponse, Error> {
        return networkingManager.download(url: url)
            .decode(type: PexelsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Fetches an image from the provided URL string.
    func fetchImage(_ urlString: String) -> AnyPublisher<Data, Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkingError.unknown)
                .eraseToAnyPublisher()
        }
        return networkingManager.download(url: url)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Constructs a URL for the given endpoint and parameters.
    private func buildURL(for endpoint: String, with parameters: [String: String]) -> Result<URL, Error> {
        var components = URLComponents(string: endpoint)
        
        if components == nil {
            return .failure(URLConstructionError.invalidEndpoint)
        }
        
        components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        if let url = components?.url {
            return .success(url)
        } else {
            return .failure(URLConstructionError.invalidParameters)
        }
    }
}
