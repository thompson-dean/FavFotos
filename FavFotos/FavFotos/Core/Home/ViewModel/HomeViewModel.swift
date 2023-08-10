//
//  HomeViewModel.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/06.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    enum ViewState {
        case idle, loading, loaded, failed
    }
    
    @Published private (set) var searchedPhotos: [Photo] = []
    @Published private (set) var curatedPhotos: [Photo] = []
    @Published private (set) var currentPage: Int = 0
    @Published private (set) var currentSearchPage: Int = 0    
    @Published var searchTerm: String = ""
    @Published private var isLoading: Bool = false
    @Published var viewState: ViewState = .idle
    
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
        guard !isLoading else { return }
        
        isLoading = true
        viewState = .loading
        currentPage += 1
        photoDataService.getPhotos(page: currentPage)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleCompletion(completion)
            }, receiveValue: { [weak self] fetchedPhotos in
                self?.curatedPhotos += fetchedPhotos
                self?.viewState = .loaded
            })
            .store(in: &cancellables)
    }
    
    func searchPhotos(searchString: String) {
        guard !isLoading else { return }
        
        isLoading = true
        viewState = .loading
        currentSearchPage += 1
        photoDataService.searchPhotos(searchTerm: searchString, page: currentSearchPage)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleCompletion(completion)
            }, receiveValue: { [weak self] fetchedPhotos in
                self?.searchedPhotos += fetchedPhotos
                self?.viewState = .loaded
            })
            .store(in: &cancellables)
    }
    
    func fetchNextSearchPhotos() {
        guard !isLoading else { return }
        
        isLoading = true
        currentSearchPage += 1
        photoDataService.searchPhotos(searchTerm: self.searchTerm, page: currentSearchPage)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleCompletion(completion)
            }, receiveValue: { [weak self] fetchedPhotos in
                self?.searchedPhotos += fetchedPhotos
                self?.viewState = .loaded
            })
            .store(in: &cancellables)
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
        isLoading = false
        switch completion {
        case .finished:
            break
        case .failure(let error):
            viewState = .failed
            printError(error)
        }
    }
    
    func printError(_ error: Error) {
        switch error {
        case NetworkingError.badRequest:
            print("Bad request error")
        case NetworkingError.unauthorized:
            print("Unauthorized request")
        case NetworkingError.forbidden:
            print("Forbidden")
        case NetworkingError.notFound:
            print("Resource not found")
        case NetworkingError.serverError:
            print("Internal server error")
        case NetworkingError.unknown:
            print("Unknown error occurred")
        case NetworkingError.urlError(let error):
            print(error.localizedDescription)
        case URLConstructionError.invalidEndpoint:
            print("Invalid endpoint")
        case URLConstructionError.invalidParameters:
            print("Invalid parameters")
        default:
            print(error.localizedDescription)
        }
    }
}
