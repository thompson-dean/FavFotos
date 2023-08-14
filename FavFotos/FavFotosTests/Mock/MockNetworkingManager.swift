//
//  MockDataManager.swift
//  FavFotosTests
//
//  Created by Dean Thompson on 2023/08/14.
//

import Foundation
import Combine
@testable import FavFotos

class MockNetworkingManager: NetworkingProtocol {
    var data: Data?
    var error: Error?

    func download(url: URL) -> AnyPublisher<Data, Error> {
        if let error = self.error {
            return Fail(outputType: Data.self, failure: error)
                .eraseToAnyPublisher()
        } 
        
        return Just(data ?? Data())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
