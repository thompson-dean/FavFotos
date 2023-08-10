//
//  CachedImageManager.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/10.
//

import Foundation
import Combine

final class CachedImageManager: ObservableObject {
    @Published private(set) var state: State?
    
    private var cancellables = Set<AnyCancellable>()
    private let photoDataService = PhotoDataService()
    
    func load(_ urlString: String, cache: ImageCache = .shared) {
        
        self.state = .loading
        if let imageData = cache.image(for: urlString) {
            self.state = .success(imageData)
            return
        }
        
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
                cache.insertImage(data, for: urlString)
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
