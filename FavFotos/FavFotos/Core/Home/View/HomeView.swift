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
                CompositionalLayoutView(items: vm.photos, id: \.self, spacing: 8) { item in
                    GeometryReader { geo in
                        CachedImage(urlString: item.src.medium) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: geo.size.width, height: geo.size.height)
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
                            if vm.hasReachedEnd(of: item) {
                                vm.fetchCuratedPhotos()
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isInputActive = false
                        }
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

struct DetailView: View {
    let urlString: String
    var body: some View {
        VStack(alignment: .center) {
            AsyncImage(url: URL(string: urlString)) { image in
                image
                    .defaultImageModifier()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } placeholder: {
                VStack(alignment: .center) {
                    ProgressView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 0)
        .navigationBarHidden(true)
    }
}


