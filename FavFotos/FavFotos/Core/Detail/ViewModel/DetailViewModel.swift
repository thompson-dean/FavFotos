//
//  DetailViewModel.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/10.
//

import Foundation

class DetailViewModel: ObservableObject {
    private var dataService = FavoritePhotosDataService()

    @Published var isPhotoLiked: Bool = false

    func checkIfPhotoIsLiked(id: Int) {
        isPhotoLiked = dataService.isPhotoLiked(id: id)
    }
    
    func likePhoto(photo: Photo) {
        if isPhotoLiked {
            if let photoEntity = dataService.getPhotoEntity(for: photo.id) {
                dataService.delete(entity: photoEntity)
                isPhotoLiked = false
            }
        } else {
            dataService.add(photo: photo)
            isPhotoLiked = true
        }
    }
}
