//
//  MockPhotoDataService.swift
//  FavFotosTests
//
//  Created by Dean Thompson on 2023/08/14.
//

import Foundation
import Combine
@testable import FavFotos

class MockPhotoDataService: PhotoDataServiceProtocol {
    
    enum Scenario {
        case success(responses: [PexelsResponse], imageData: Data?)
        case failure(error: Error, imageError: Error?)
    }
    
    let scenario: Scenario
    
    init(scenario: Scenario) {
        self.scenario = scenario
    }
    
    func getPhotos(page: Int) -> AnyPublisher<PexelsResponse, Error> {
        switch scenario {
        case .success(let responses, _):
            if page <= responses.count {
                return Just(responses[page - 1])
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                let error = MockError.responseError
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        case .failure(let error, _):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func searchPhotos(searchTerm: String, page: Int) -> AnyPublisher<PexelsResponse, Error> {
        switch scenario {
        case .success(let responses, _):
            if page <= responses.count {
                return Just(responses[page - 1])
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                let error = MockError.responseError
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        case .failure(let error, _):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchImage(_ urlString: String) -> AnyPublisher<Data, Error> {
        switch scenario {
        case .success(_, let imageData):
            if let data = imageData {
                return Just(data)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                let error = MockError.imageError
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        case .failure(_, let imageError):
            if let error = imageError {
                return Fail(error: error)
                    .eraseToAnyPublisher()
            } else {
                let error = MockError.imageError
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        }
    }
}

enum MockError: LocalizedError {
    case responseError
    case imageError
}




