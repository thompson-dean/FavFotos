//
//  PhotoDataServiceTests.swift
//  FavFotosTests
//
//  Created by Dean Thompson on 2023/08/14.
//

import XCTest
import Combine
@testable import FavFotos

// test_methodName_withCircumstances_shouldExpectation

class PhotoDataServiceTests: XCTestCase {

    var mockNetworkManager: MockNetworkingManager!
    var photoDataService: PhotoDataService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        let mockData = loadMockData(from: "mock_data", fileType: "json")
        XCTAssertNotNil(mockData, "Failed to load mock data.")

        mockNetworkManager = MockNetworkingManager()
        mockNetworkManager.data = mockData
        photoDataService = PhotoDataService(networkingManager: mockNetworkManager)
        cancellables = []
    }

    override func tearDown() {
        mockNetworkManager = nil
        photoDataService = nil
        cancellables = nil

        super.tearDown()
    }

    func loadMockData(from fileName: String, fileType: String) -> Data? {
        if let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: fileType) {
            return try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
        }
        return nil
    }

    func test_getPhotos_withSuccess_shouldBeFivePhotos() {
        let expectation = XCTestExpectation(description: "Should retrieve photos.")

        photoDataService.getPhotos(page: 1)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        XCTFail("Expected success, but got \(error) instead.")
                    }
                    expectation.fulfill()
                },
                receiveValue: { response in
                    XCTAssertEqual(response.photos.count, 5, "Expected 5 photos from mock data.")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_getPhotos_withFailure_shouldBeZeroPhotos() {
        mockNetworkManager.error = NetworkingError.clientError(message: "Simulated Failure")
        
        let expectation = XCTestExpectation(description: "Should fail to retrieve photos.")

        photoDataService.getPhotos(page: 1)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Expected failure, but received success instead.")
                    case .failure(let error):
                        // Confirm that you received the expected error.
                        if case NetworkingError.clientError(let message) = error {
                            XCTAssertEqual(message, "Simulated Failure")
                        } else {
                            XCTFail("Received unexpected error: \(error)")
                        }
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("Shouldn't receive any values upon failure.")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_searchPhotos_withSuccess_shouldBeFivePhotos() {
        let expectation = XCTestExpectation(description: "Should retrieve photos upon successful search.")

        photoDataService.searchPhotos(searchTerm: "test", page: 1)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        XCTFail("Expected success, but got \(error) instead.")
                    }
                    expectation.fulfill()
                },
                receiveValue: { response in
                    XCTAssertEqual(response.photos.count, 5, "Expected 5 photos from mock data upon search.")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_searchPhotos_withFailure_shouldBeZeroPhotos() {

        mockNetworkManager.error = NetworkingError.clientError(message: "Simulated Failure")

        let expectation = XCTestExpectation(description: "Should fail to retrieve photos upon search.")

        photoDataService.searchPhotos(searchTerm: "test", page: 1)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Expected failure, but received success instead.")
                    case .failure(let error):
                        if case NetworkingError.clientError(let message) = error {
                            XCTAssertEqual(message, "Simulated Failure")
                        } else {
                            XCTFail("Received unexpected error: \(error)")
                        }
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("Shouldn't receive any values upon failure.")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_fetchImage_withSuccess_shouldReturnData() {
        let expectation = XCTestExpectation(description: "Should retrieve image data.")

        photoDataService.fetchImage("https://mock_image_url.com")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        XCTFail("Expected success, but got \(error) instead.")
                    }
                    expectation.fulfill()
                },
                receiveValue: { data in
                    XCTAssertGreaterThan(data.count, 0, "Expected non-empty image data.")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_fetchImage_withFailure_shouldReturnError() {
        mockNetworkManager.error = NetworkingError.clientError(message: "Simulated Failure")

        let expectation = XCTestExpectation(description: "Should fail to retrieve image data.")

        photoDataService.fetchImage("https://mock_image_url.com")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Expected failure, but received success instead.")
                    case .failure(let error):
                        if case NetworkingError.clientError(let message) = error {
                            XCTAssertEqual(message, "Simulated Failure")
                        } else {
                            XCTFail("Received unexpected error: \(error)")
                        }
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("Shouldn't receive any values upon failure.")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}
