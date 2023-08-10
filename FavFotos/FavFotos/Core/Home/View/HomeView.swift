//
//  HomeView.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/05.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm = HomeViewModel()
    @FocusState private var isInputActive: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                switch vm.viewState {
                case .idle:
                    CompositionalLayoutView(items: 0..<12, id: \.self, spacing: 8) { index in
                        GeometryReader { geo in
                            Image(systemName: "photo")
                                .defaultImageModifier()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .cornerRadius(4)
                                .redacted(reason: .placeholder)
                        }
                    }
                case .loading:
                    CompositionalLayoutView(items: 0..<12, id: \.self, spacing: 8) { index in
                        GeometryReader { geo in
                            Image(systemName: "photo")
                                .defaultImageModifier()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .cornerRadius(4)
                                .redacted(reason: .placeholder)
                        }
                    }
                case .loaded:
                    CompositionalLayoutView(items: vm.photos, id: \.self, spacing: 8) { photo in
                        NavigationLink {
                            DetailView(photo: photo)
                        } label: {
                            GeometryReader { geo in
                                CachedImage(urlString: photo.src.large) { phase in
                                    switch phase {
                                    case .empty:
                                        Image(systemName: "photo")
                                            .defaultImageModifier()
                                            .frame(width: geo.size.width, height: geo.size.height)
                                            .cornerRadius(4)
                                            .redacted(reason: .placeholder)
                                    case.failure(let error):
                                        Image(systemName: "exclamationmark.triangle")
                                            .defaultImageModifier()
                                            .frame(width: geo.size.width, height: geo.size.height)
                                            .cornerRadius(4)
                                    case .success(let image):
                                        image
                                            .defaultImageModifier()
                                            .frame(width: geo.size.width, height: geo.size.height)
                                            .cornerRadius(4)
                                    default:
                                        EmptyView()
                                    }
                                }
                                .onAppear {
                                    if vm.hasReachedEnd(of: photo) {
                                        vm.fetchMorePhotos()
                                    }
                                }
                            }
                        }
                    }
                case .failed:
                    VStack {
                        Text("Failed")
                    }
                }
                
            }
            .padding(8)
            .navigationTitle("FavFotos")
        }
        .searchable(text: $vm.searchTerm)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


