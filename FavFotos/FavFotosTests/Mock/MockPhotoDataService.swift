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
    
    var shouldReturnError: Bool = false
    private var mockPexelsResponse: PexelsResponse?
    
    init() {
        if let mockData = loadMockData(from: "mock_data", fileType: "json") {
            mockPexelsResponse = try? JSONDecoder().decode(PexelsResponse.self, from: mockData)
        }
    }
    
    func getPhotos(page: Int) -> AnyPublisher<PexelsResponse, Error> {
        return responsePublisher()
    }
    
    func searchPhotos(searchTerm: String, page: Int) -> AnyPublisher<PexelsResponse, Error> {
        return responsePublisher()
    }
    
    func fetchImage(_ urlString: String) -> AnyPublisher<Data, Error> {
        return Just(Data())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func loadMockData(from fileName: String, fileType: String) -> Data? {
        if let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: fileType) {
            return try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
        }
        return nil
    }
    
    private func responsePublisher() -> AnyPublisher<PexelsResponse, Error> {
        if shouldReturnError {
            return Fail(error: MockError.simulatedError)
                .eraseToAnyPublisher()
        } else if let response = mockPexelsResponse {
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: MockError.simulatedError)
                .eraseToAnyPublisher()
        }
    }
}

enum MockError: Error {
    case simulatedError
}




