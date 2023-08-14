//
//  CachedImageManager.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/10.
//

import Foundation
import Combine

/// An observable object that manages the retrieval of cached images, loading them from the network if necessary.
final class CachedImageManager: ObservableObject {
    
    /// Represents the current state of the image load request.
    @Published private(set) var state: State?
    
    /// Collection of any active data request cancellables.
    private var cancellables = Set<AnyCancellable>()
    
    /// Service responsible for fetching images.
    private let photoDataService = PhotoDataService()
    
    /// Attempts to load an image for a given ID and URL. It first checks the cache, and if unavailable, fetches from the network.
    func load(for id: Int, urlString: String, cache: ImageCache = .shared) {
        
        self.state = .loading
        
        // Check cache first
        if let imageData = cache.image(for: id) {
            self.state = .success(imageData)
            return
        }
        
        // If not in cache, fetch from network
        photoDataService.fetchImage(urlString)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.state = .failed(error)
                }
            }, receiveValue: { [weak self] data in
                self?.state = .success(data)
                cache.insertImage(data, for: id) // Store fetched data in cache
            })
            .store(in: &cancellables)
    }
}

extension CachedImageManager {
    enum State {
        case loading
        case failed(_ error: Error)
        case success(_ data: Data)
    }
}
