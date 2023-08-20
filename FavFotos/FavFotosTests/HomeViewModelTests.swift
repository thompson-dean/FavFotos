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
    let response: PexelsResponse = Bundle(for: HomeViewModelTests.self).decode("mock_data.json")
    let response2: PexelsResponse = Bundle(for: HomeViewModelTests.self).decode("mock_data2.json")
    let response3: PexelsResponse = Bundle(for: HomeViewModelTests.self).decode("mock_data3.json")
    
    override func setUp() {
        super.setUp()
        let responses: [PexelsResponse] = [response, response2, response3]
        mockService = MockPhotoDataService(scenario: .success(responses: responses, imageData: nil))
        viewModel = HomeViewModel(photoDataService: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil

        super.tearDown()
    }
    
    func test_HomeViewModel_init_curatedPhotosShouldBeFetched() {
        let expectation = XCTestExpectation(description: "Fetched curated photos on init successfully")
        
        viewModel.$curatedPhotos
            .sink { photos in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(viewModel.state == .loaded)
        XCTAssertFalse(viewModel.curatedPhotos.isEmpty)
        XCTAssertEqual(viewModel.curatedPhotos.count, 5)
    }
    
    func test_HomeViewModel_init_curatedPhotosShouldNotBeFetchedBecauseError() {
        let expectation = XCTestExpectation(description: "Fetched curated photos on init successfully")
        
        mockService = MockPhotoDataService(scenario: .failure(error: MockError.responseError, imageError: nil))
        viewModel = HomeViewModel(photoDataService: mockService)
        
        viewModel.$curatedPhotos
            .sink { photos in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(viewModel.state == .error("An unexpected error occurred. Please try again."))
        XCTAssertFalse(!viewModel.curatedPhotos.isEmpty)
        XCTAssertEqual(viewModel.curatedPhotos.count, 0)
    }
    
    func test_HomeViewModel_fetchCuratedPhotos_curatedPhotosShouldIncreaseThroughPagination() {
        let expectation = XCTestExpectation(description: "Fetched curated photos on init successfully")
        expectation.expectedFulfillmentCount = 2

        viewModel.$curatedPhotos
            .sink { photos in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchCuratedPhotos()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(viewModel.state == .loaded)
        XCTAssertFalse(viewModel.curatedPhotos.isEmpty)
        XCTAssertEqual(viewModel.curatedPhotos.count, 8)
    }
    
    func test_HomeViewModel_fetchCuratedPhotos_curatedPhotosShouldIncreaseThroughPagination_stress() {
        let expectation = XCTestExpectation(description: "Fetched curated photos on init successfully")
        let loopCount = Int.random(in: 1..<40)
        expectation.expectedFulfillmentCount = loopCount
        var responses: [PexelsResponse] = []
        
        for _ in 0..<loopCount {
            responses.append(response)
        }
        mockService = MockPhotoDataService(scenario: .success(responses: responses, imageData: nil))
        viewModel = HomeViewModel(photoDataService: mockService)
        
        viewModel.$curatedPhotos
            .sink { photos in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        for _ in 0..<loopCount - 1 {
            viewModel.fetchCuratedPhotos()
        }
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(viewModel.state == .loaded)
        XCTAssertFalse(viewModel.curatedPhotos.isEmpty)
        XCTAssertEqual(viewModel.curatedPhotos.count, loopCount * 5)
    }
    
    func test_HomeViewModel_fetchCuratedPhotos_willNotFetchWhenLoadingState() {
        viewModel.state = .loading
        
        viewModel.fetchCuratedPhotos()
        
        XCTAssertTrue(!viewModel.curatedPhotos.isEmpty)
        XCTAssertEqual(viewModel.curatedPhotos.count, 5)
    }
    
    func test_HomeViewModel_searchPhotos_searchedPhotosShouldBeFetched() {
        let expectation = XCTestExpectation(description: "Fetched search photos successfully")
        
        viewModel.$searchedPhotos
            .sink { photos in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchTerm = "test"
        viewModel.searchPhotos(searchString: viewModel.searchTerm)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(viewModel.state == .loaded)
        XCTAssertFalse(viewModel.searchedPhotos.isEmpty)
        XCTAssertEqual(viewModel.searchedPhotos.count, 5)
    }
    
    func test_HomeViewModel_searchPhotos_searchedPhotosShouldNotBeFetchedBecauseError() {
        let expectation = XCTestExpectation(description: "Fetch search photos failed")
        
        mockService = MockPhotoDataService(scenario: .failure(error: MockError.responseError, imageError: nil))
        viewModel = HomeViewModel(photoDataService: mockService)
        
        viewModel.$searchedPhotos
            .sink { photos in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchTerm = "test"
        viewModel.searchPhotos(searchString: viewModel.searchTerm)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(viewModel.state == .error("An unexpected error occurred. Please try again."))
        XCTAssertTrue(viewModel.searchedPhotos.isEmpty)
        XCTAssertEqual(viewModel.searchedPhotos.count, 0)
    }
    
    func test_HomeViewModel_searchPhotos_searchedPhotosShouldIncreaseThroughPagination() {
        let expectation = XCTestExpectation(description: "Fetched search photos through pagination")
        expectation.expectedFulfillmentCount = 2

        viewModel.$searchedPhotos
            .sink { photos in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchTerm = "test"
        viewModel.searchPhotos(searchString: viewModel.searchTerm)
        
        viewModel.fetchNextSearchPhotos()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(viewModel.state == .loaded)
        XCTAssertFalse(viewModel.searchedPhotos.isEmpty)
        XCTAssertEqual(viewModel.searchedPhotos.count, 8)
    }
    
    func test_HomeViewModel_searchPhotos_searchedPhotosShouldIncreaseThroughPagination_stress() {
        let expectation = XCTestExpectation(description: "Fetched search photos through pagination stress test")
        let loopCount = Int.random(in: 1..<40)
        expectation.expectedFulfillmentCount = loopCount
        var responses: [PexelsResponse] = []
        
        for _ in 0..<loopCount {
            responses.append(response)
        }
        mockService = MockPhotoDataService(scenario: .success(responses: responses, imageData: nil))
        viewModel = HomeViewModel(photoDataService: mockService)
        
        viewModel.$searchedPhotos
            .sink { photos in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchTerm = "test"
        viewModel.searchPhotos(searchString: viewModel.searchTerm)
        
        for _ in 0..<loopCount - 1 {
            viewModel.fetchNextSearchPhotos()
        }
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(viewModel.searchedPhotos.isEmpty)
        XCTAssertEqual(viewModel.searchedPhotos.count, loopCount * 5)
    }
    
    func test_HomeViewModel_searchPhotos_willNotFetchWhenLoadingState() {
        viewModel.state = .loading
        
        viewModel.searchTerm = "test"
        viewModel.searchPhotos(searchString: viewModel.searchTerm)
        
        XCTAssertTrue(viewModel.searchedPhotos.isEmpty)
        XCTAssertEqual(viewModel.searchedPhotos.count, 0)
    }
    
    func test_HomeViewModel_fetchNextSearchPhotos_willNotFetchWhenLoadingState() {
        let expectation = XCTestExpectation(description: "Search photos will not fetch in loading state.")
        
        viewModel.searchTerm = "test"
        viewModel.searchPhotos(searchString: viewModel.searchTerm)
        
        viewModel.$searchedPhotos
            .sink { photos in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.state = .loading
        viewModel.fetchNextSearchPhotos()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(viewModel.searchedPhotos.count, 5)
    }
    
    func test_HomeViewModel_reset_resetsViewModel() {
        viewModel.searchTerm = "test"
        viewModel.searchPhotos(searchString: viewModel.searchTerm)
        
        viewModel.reset()
        
        XCTAssertEqual(viewModel.searchedPhotos.count, 5)
        XCTAssertEqual(viewModel.curatedPhotos.count, 5)
        XCTAssertEqual(viewModel.currentSearchPage, 1)
        XCTAssertEqual(viewModel.currentPage, 1)
    }
    
    func test_HomeViewModel_hasReachedEnd_returnsTrueWhenPhotoIsLastInList() {
        let lastPhoto = viewModel.curatedPhotos.last!
        
        XCTAssertTrue(viewModel.hasReachedEnd(of: lastPhoto))
    }
    
    func test_HomeViewModel_hasReachedEnd_returnsFalseWhenPhotoIsNotLastInList() {
        
        let notLastPhoto = viewModel.curatedPhotos.first!
        
        XCTAssertFalse(viewModel.hasReachedEnd(of: notLastPhoto))
    }
    
    func test_HomeViewModel_fetchMorePhotos_fetchesNextSearchPhotosIfSearching() {
        let expectation = XCTestExpectation(description: "Fetched more photos while searching.")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.$searchedPhotos
            .sink { photos in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchTerm = "test"
        viewModel.searchPhotos(searchString: viewModel.searchTerm)
        
        viewModel.fetchMorePhotos()
        
        wait(for: [expectation], timeout: 5)
        XCTAssertFalse(viewModel.searchedPhotos.isEmpty)
        XCTAssertEqual(viewModel.searchedPhotos.count, 8)
    }
    
    func test_HomeViewModel_fetchMorePhotos_fetchesCuratedPhotosIfNotSearching() {
        let expectation = XCTestExpectation(description: "Fetched more curated photos while not searching.")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.$curatedPhotos
            .sink { photos in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchMorePhotos()
        
        wait(for: [expectation], timeout: 5)
        XCTAssertFalse(viewModel.curatedPhotos.isEmpty)
        XCTAssertEqual(viewModel.curatedPhotos.count, 8)
    }
    
    func test_HomeViewModel_updateImageQuality_resetsViewModel() {
        
        let expectation = XCTestExpectation(description: "reset viewModel on change of image quality")
        
        viewModel.$curatedPhotos
            .sink { photos in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        viewModel.updateImageQuality(to: .high)
    
        
        XCTAssertEqual(viewModel.selectedImageQuality, .high)
        XCTAssertEqual(viewModel.curatedPhotos.count, 5)
        XCTAssertEqual(viewModel.currentSearchPage, 0)
        XCTAssertEqual(viewModel.currentPage, 1)
    }
}
