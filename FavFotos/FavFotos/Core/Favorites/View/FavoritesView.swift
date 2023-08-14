//
//  FavoritesView.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/10.
//

import SwiftUI

struct FavoritesView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var vm = FavoritesViewModel()
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if vm.favoritePhotos.isEmpty {
                    VStack(alignment: .center, spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                        Text("No favorites yet? Start exploring photos")
                            .font(.title2)
                        
                    }
                    .padding(16)
                    .background(colorScheme == .light ? .black.opacity(0.1) : .white.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.top, 64)
                } else {
                    ZStack {
                    CompositionalLayoutView(items: vm.favoritePhotos, id: \.id, spacing: 8) { photo in
                        NavigationLink {
                            DetailView(source: .entity(photo))
                        } label: {
                            GeometryReader { geo in
                                if let data = photo.image, let image = UIImage(data: data) {
                                    Image(uiImage: image)
                                        .defaultImageModifier()
                                        .frame(width: geo.size.width, height: geo.size.height)
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
                .padding(8)
                }
            }
            .onAppear {
                vm.fetchFavorites()
            }
            .navigationBarTitle("Favorites", displayMode: .large)
        }
    }
}
