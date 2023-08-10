//
//  HomeViewModel.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/06.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published private (set) var searchedPhotos: [Photo] = []
    @Published private (set) var curatedPhotos: [Photo] = []
    @Published private (set) var currentPage: Int = 0
    @Published var searchTerm: String = ""
    
    private let photoDataService = PhotoDataService()
    private var cancellables = Set<AnyCancellable>()
    
    var photos: [Photo] {
        if searchTerm.isEmpty {
            return curatedPhotos
        } else {
            return searchedPhotos
        }
    }
    
    init() {
        fetchCuratedPhotos()
        listenToSearch()
    }
    
    func listenToSearch() {
        $searchTerm
            .debounce(for: .milliseconds(350), scheduler: RunLoop.main, options: .none)
            .removeDuplicates()
            .sink { [weak self] delayQuery in
                if !delayQuery.isEmpty {
                    self?.searchPhotos(searchString: delayQuery)
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchCuratedPhotos() {
        currentPage += 1
        print("DEBUG: \(currentPage)")
        photoDataService.getPhotos(page: currentPage)
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] fetchedPhotos in
                self?.curatedPhotos += fetchedPhotos
            })
            .store(in: &cancellables)
    }
    
    func fetchNextCuratedPhotos() {
        currentPage += 1
        print("DEBUG: \(currentPage)")
        photoDataService.getPhotos(page: currentPage)
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] fetchedPhotos in
                self?.curatedPhotos += fetchedPhotos
            })
            .store(in: &cancellables)
    }
    
    func searchPhotos(searchString: String) {
        photoDataService.searchPhotos(searchTerm: searchString)
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] fetchedPhotos in
                self?.searchedPhotos = fetchedPhotos
            })
            .store(in: &cancellables)
    }
    
    func hasReachedEnd(of photo: Photo) -> Bool {
        curatedPhotos.last?.id == photo.id
    }
}
