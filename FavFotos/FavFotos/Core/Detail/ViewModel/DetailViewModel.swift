//
//  DetailViewModel.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/10.
//

import Foundation

class DetailViewModel: ObservableObject {
    
    @Published var isPhotoLiked: Bool = false
    
    private var dataService: FavoritePhotosDataServiceProtocol
    
    init(dataService: FavoritePhotosDataServiceProtocol = FavoritePhotosDataService()) {
        self.dataService = dataService
    }
    
    func checkIfPhotoIsLiked(source: DetailSource) {
        let id: Int
        switch source {
        case .photo(let photo):
            id = photo.id
        case .entity(let entity):
            id = Int(entity.id)
        }
        isPhotoLiked = dataService.isPhotoLiked(id: id)
    }
    
    func likePhoto(source: DetailSource) {
        let id: Int
        switch source {
        case .photo(let photo):
            id = photo.id
        case .entity(let entity):
            id = Int(entity.id)
        }
        
        if isPhotoLiked {
            if let photoEntity = dataService.getPhotoEntity(for: id) {
                dataService.delete(entity: photoEntity)
                isPhotoLiked = false
            }
        } else {
            switch source {
            case .photo(let photo):
                dataService.add(photo: photo)
            case .entity:
                break
            }
            isPhotoLiked = true
        }
    }
}
