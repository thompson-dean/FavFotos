//
//  PhotoDataService.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/05.
//

import Foundation
import Combine

class PhotoDataService {
    
    func getPhotos() -> AnyPublisher<[Photo], Error> {
        guard let url = URL(string: Constants.api) else {
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
        guard let url = URL(string: "https://api.pexels.com/v1/search?query=\(searchTerm)&per_page=1") else {
            return Fail(error: NetworkingManager.NetworkingError.unknown)
                   .eraseToAnyPublisher()
        }

        return NetworkingManager.download(url: url)
            .decode(type: PexelsResponse.self, decoder: JSONDecoder())
            .map(\.photos)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
