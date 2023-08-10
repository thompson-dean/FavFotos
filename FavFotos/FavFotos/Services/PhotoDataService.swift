//
//  PhotoDataService.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/05.
//

import Foundation
import Combine

enum URLConstructionError: Error {
    case invalidEndpoint
    case invalidParameters
}

protocol PhotoDataServiceProtocol {
    func getPhotos(page: Int) -> AnyPublisher<[Photo], Error>
    func searchPhotos(searchTerm: String, page: Int) -> AnyPublisher<[Photo], Error>
    func fetchImage(_ urlString: String) -> AnyPublisher<Data, Error>
}

class PhotoDataService: PhotoDataServiceProtocol {
    
    private let networkingManager: NetworkingProtocol
    
    init(networkingManager: NetworkingProtocol = NetworkingManager()) {
        self.networkingManager = networkingManager
    }
    
    func getPhotos(page: Int = 1) -> AnyPublisher<[Photo], Error> {
        let parameters: [String: String] = [
            "page": "\(page)",
            "per_page": "\(Constants.perPage)"
        ]
        
        switch buildURL(for: Constants.curatedAPI, with: parameters) {
        case .success(let url):
            return fetchPhotos(from: url)
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func searchPhotos(searchTerm: String, page: Int = 1) -> AnyPublisher<[Photo], Error> {
        let parameters: [String: String] = [
            "query": searchTerm,
            "page": "\(page)",
            "per_page": "\(Constants.perPage)"
        ]
        
        switch buildURL(for: Constants.searchAPI, with: parameters) {
        case .success(let url):
            return fetchPhotos(from: url)
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    private func fetchPhotos(from url: URL) -> AnyPublisher<[Photo], Error> {
        return networkingManager.download(url: url)
            .decode(type: PexelsResponse.self, decoder: JSONDecoder())
            .map(\.photos)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchImage(_ urlString: String) -> AnyPublisher<Data, Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkingError.unknown)
                .eraseToAnyPublisher()
        }
        return networkingManager.download(url: url)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
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
