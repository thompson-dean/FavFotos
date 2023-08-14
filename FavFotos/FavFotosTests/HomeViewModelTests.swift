//
//  HomeViewModelTests.swift
//  FavFotosTests
//
//  Created by Dean Thompson on 2023/08/14.
//

import XCTest
import Combine
@testable import FavFotos

class HomeViewModelTests: XCTestCase {
    
    var viewModel: HomeViewModel!
    var mockService: MockPhotoDataService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        
        mockService = MockPhotoDataService()
        viewModel = HomeViewModel(photoDataService: mockService, fetchOnInit: false)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil

        super.tearDown()
    }
    
    func test_fetchCuratedPhotos_withSuccess_shouldReturnFivePhotos() {
        let expectation = XCTestExpectation(description: "Fetched curated photos successfully")
        var receivedPhotos: [Photo] = []
        
        viewModel.$curatedPhotos
            .dropFirst()
            .sink { (photos) in
                receivedPhotos = photos
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchCuratedPhotos()
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(receivedPhotos.isEmpty, "No photos were received.")
        XCTAssertEqual(receivedPhotos.count, 5, "Received photos are not as expected.")
    }

    func test_fetchCuratedPhotos_withFailure_shouldReturnErrorState() {
        mockService.shouldReturnError = true
        let expectation = XCTestExpectation(description: "Received an error while fetching photos")
        var receivedPhotos: [Photo] = []
        var receivedState: HomeViewModel.ViewModelState = .idle
        
        viewModel.$curatedPhotos
            .dropFirst()
            .sink { (photos) in
                receivedPhotos = photos
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                receivedState = state
                print(receivedState)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchCuratedPhotos()
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(receivedPhotos.isEmpty, "Photos should be empty when an error occurs")
        XCTAssertEqual(receivedState, .error("An unexpected error occurred. Please try again."), "Received state is not as expected.")
    }
    
    func test_searchPhotos_withSuccess_shouldReturnSearchedPhotos() {
        let expectation = XCTestExpectation(description: "Searched photos successfully fetched")
        var receivedPhotos: [Photo] = []
        
        viewModel.$searchedPhotos
            .dropFirst()
            .sink { (photos) in
                receivedPhotos = photos
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchTerm = "Nature"
        viewModel.searchPhotos(searchString: "Nature")
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(receivedPhotos.isEmpty, "No photos were received for the search term.")
    }
    
    func test_searchPhotos_withFailure_shouldReturnErrorState() {
        mockService.shouldReturnError = true
        let expectation = XCTestExpectation(description: "Received an error while searching photos")
        var receivedPhotos: [Photo] = []
        var receivedState: HomeViewModel.ViewModelState = .idle
        
        viewModel.$searchedPhotos
            .dropFirst()
            .sink { (photos) in
                receivedPhotos = photos
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                receivedState = state
                print(receivedState)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchTerm = "Nature"
        viewModel.searchPhotos(searchString: "Nature")
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(receivedPhotos.isEmpty, "Photos should be empty when an error occurs")
        XCTAssertEqual(receivedState, .error("An unexpected error occurred. Please try again."), "Received state is not as expected.")
    }
    
    func test_updateImageQuality_shouldResetAndFetch() {
        let expectation = XCTestExpectation(description: "Image quality updated and photos fetched")
        var receivedPhotos: [Photo] = []
        
        viewModel.$curatedPhotos
            .dropFirst(2)
            .sink { (photos) in
                receivedPhotos = photos
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.updateImageQuality(to: .high)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(receivedPhotos.isEmpty, "No photos were received after updating image quality.")
    }
    
    func test_fetchMorePhotos_whenNotSearching_shouldFetchCuratedPhotos() {
        let expectation = XCTestExpectation(description: "Fetched more curated photos")
        var receivedPhotos: [Photo] = []
        
        viewModel.$curatedPhotos
            .dropFirst()
            .sink { (photos) in
                receivedPhotos = photos
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchMorePhotos()
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(receivedPhotos.isEmpty, "No photos were received when trying to fetch more curated photos.")
    }
    
    func test_fetchCuratedPhotos_pagination_shouldFetchAndAppendData() {
        let expectation1 = XCTestExpectation(description: "Fetched first page")
        let expectation2 = XCTestExpectation(description: "Fetched second page")
        
        viewModel.$curatedPhotos
            .dropFirst()
            .sink { [self] (photos) in
                if viewModel.currentPage == 1 {
                    expectation1.fulfill()
                } else if viewModel.currentPage == 2 {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.fetchCuratedPhotos()
        wait(for: [expectation1], timeout: 1.0)
        
        viewModel.fetchCuratedPhotos()
        wait(for: [expectation2], timeout: 1.0)
        
        XCTAssertGreaterThanOrEqual(viewModel.curatedPhotos.count, 2, "Should have fetched and appended two pages of data")
    }
    
    func test_fetchNextSearchPhotos_pagination_shouldFetchAndAppendData() {
        let expectation1 = XCTestExpectation(description: "Fetched first page")
        let expectation2 = XCTestExpectation(description: "Fetched second page")
        
        viewModel.$searchedPhotos
            .dropFirst()
            .sink { [self] (photos) in
                if viewModel.currentSearchPage == 1 {
                    expectation1.fulfill()
                } else if viewModel.currentSearchPage == 2 {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.searchPhotos(searchString: "Jazz")
        wait(for: [expectation1], timeout: 1.0)
        
        viewModel.searchTerm = "Jazz"
        viewModel.fetchNextSearchPhotos()
        wait(for: [expectation2], timeout: 1.0)
        
        XCTAssertGreaterThanOrEqual(viewModel.searchedPhotos.count, 2, "Should have fetched and appended two pages of data")
    }
}
