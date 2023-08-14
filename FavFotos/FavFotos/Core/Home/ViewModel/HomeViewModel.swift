//
//  HomeViewModel.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/06.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    enum ViewModelState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    @Published private (set) var searchedPhotos: [Photo] = []
    @Published private (set) var curatedPhotos: [Photo] = []
    @Published private (set) var currentPage: Int = 0
    @Published private (set) var currentSearchPage: Int = 0
    @Published var searchTerm: String = ""
    @Published var isLoading: Bool = false
    @Published var state: ViewModelState = .idle
    @Published var selectedImageQuality: ImageQuality = .medium
    
    private var nextSearchPageURL: String? = nil
    private let photoDataService: PhotoDataServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(photoDataService: PhotoDataServiceProtocol = PhotoDataService()) {
        self.photoDataService = photoDataService
        fetchCuratedPhotos()
        listenToSearch()
    }
    
    var photos: [Photo] {
        if searchTerm.isEmpty {
            return curatedPhotos
        } else {
            return searchedPhotos
        }
    }
    
    var isSearching: Bool {
        return !searchTerm.isEmpty
    }
    
    func listenToSearch() {
        $searchTerm
            .debounce(for: .milliseconds(350), scheduler: RunLoop.main, options: .none)
            .removeDuplicates()
            .sink { [weak self] delayQuery in
                self?.searchedPhotos = []
                self?.currentSearchPage = 0
                if !delayQuery.isEmpty {
                    self?.searchPhotos(searchString: delayQuery)
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchCuratedPhotos() {
        guard state != .loading else { return }
        
        state = .loading
        currentPage += 1
        photoDataService.getPhotos(page: currentPage)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleCompletion(completion)
            }, receiveValue: { [weak self] pexelsResponse in
                self?.curatedPhotos += pexelsResponse.photos
            })
            .store(in: &cancellables)
    }
    
    func searchPhotos(searchString: String) {
        guard state != .loading else { return }
        
        state = .loading
        currentSearchPage += 1
        photoDataService.searchPhotos(searchTerm: searchString, page: currentSearchPage)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleCompletion(completion)
            }, receiveValue: { [weak self] pexelsResponse in
                self?.nextSearchPageURL = pexelsResponse.nextPage
                self?.searchedPhotos += pexelsResponse.photos
            })
            .store(in: &cancellables)
    }
    
    func fetchNextSearchPhotos() {
        guard state != .loading, let _ = nextSearchPageURL else { return }
        
        state = .loading
        currentSearchPage += 1
        photoDataService.searchPhotos(searchTerm: self.searchTerm, page: currentSearchPage)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleCompletion(completion)
            }, receiveValue: { [weak self] pexelsResponse in
                self?.nextSearchPageURL = pexelsResponse.nextPage
                self?.searchedPhotos += pexelsResponse.photos
            })
            .store(in: &cancellables)
    }
    
    func reset() {
        if isSearching {
            searchedPhotos = []
            currentSearchPage = 0
            fetchNextSearchPhotos()
        } else {
            curatedPhotos = []
            currentPage = 0
            fetchCuratedPhotos()
        }
    }
    
    func hasReachedEnd(of photo: Photo) -> Bool {
        return photos.last?.id == photo.id
    }
    
    func fetchMorePhotos() {
        if isSearching {
            fetchNextSearchPhotos()
        } else {
            fetchCuratedPhotos()
        }
    }
    
    func handleCompletion(_ completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            state = .loaded
        case .failure(let error):
            let errorMessage = ErrorHandler.userFriendlyMessage(from: error)
            state = .error(errorMessage)
            print(errorMessage)
        }
        isLoading = false
    }
    
    func updateImageQuality(to quality: ImageQuality) {
        self.selectedImageQuality = quality
        self.reset()
    }
}
