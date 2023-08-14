//
//  FavoritesViewModel.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/10.
//

import SwiftUI

class FavoritesViewModel: ObservableObject {
    
    @Published var favoritePhotos: [PhotoEntity] = []
    private var dataService = FavoritePhotosDataService()
    
    init() {
        fetchFavorites()
    }
    
    func fetchFavorites() {
        favoritePhotos = dataService.getFavorites()
    }
}
