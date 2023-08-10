//
//  PhotoDataService.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/05.
//

import Foundation
import Combine

class PhotoDataService {
    
    func getPhotos(page: Int = 1) -> AnyPublisher<[Photo], Error> {
        let urlStr = "\(Constants.api)?page=\(page)&per_page=\(Constants.perPage)"
        
        guard let url = URL(string: urlStr) else {
            return Fail(error: NetworkingManager.NetworkingError.unknown)
                   .eraseToAnyPublisher()
        }
        return NetworkingManager.download(url: url)
            .decode(type: PexelsResponse.self, decoder: JSONDecoder())
            .map(\.photos)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func searchPhotos(searchTerm: String) -> AnyPublisher<[Photo], Error> {
        guard let url = URL(string: "https://api.pexels.com/v1/search?query=\(searchTerm)&per_page=15") else {
            return Fail(error: NetworkingManager.NetworkingError.unknown)
                   .eraseToAnyPublisher()
        }

        return NetworkingManager.download(url: url)
            .decode(type: PexelsResponse.self, decoder: JSONDecoder())
            .map(\.photos)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchImage(_ urlString: String) -> AnyPublisher<Data, Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkingManager.NetworkingError.unknown)
                   .eraseToAnyPublisher()
        }
        return NetworkingManager.download(url: url)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
