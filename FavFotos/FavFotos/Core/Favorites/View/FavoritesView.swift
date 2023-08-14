//
//  FavoritesView.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/10.
//

import SwiftUI

struct FavoritesView: View {
    
    @ObservedObject var vm = FavoritesViewModel()
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(vm.favoritePhotos, id: \.self) { photoEntity in
                    if let data = photoEntity.image, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            vm.fetchFavorites()
        }
        .navigationBarTitle("Favorites", displayMode: .large)
    }
}
