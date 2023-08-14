//
//  FavoritesViewModel.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/10.
//

import SwiftUI

class FavoritesViewModel: ObservableObject {
    
    @Published var favoritePhotos: [PhotoEntity] = []
    private var dataService: FavoritePhotosDataServiceProtocol
    
    init(dataService: FavoritePhotosDataServiceProtocol = FavoritePhotosDataService()) {
        self.dataService = dataService
    }
    
    func fetchFavorites() {
        favoritePhotos = dataService.getFavorites()
    }
}
