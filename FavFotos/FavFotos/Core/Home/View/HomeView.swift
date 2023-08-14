//
//  HomeView.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/05.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var vm = HomeViewModel()
    @FocusState private var isInputActive: Bool
    @State private var isHighQuality: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    switch vm.state {
                    case .loaded, .idle, .loading:
                        ScrollView {
                            self.photosView()
                                .padding(.bottom, 24)
                        }
                        .overlay(alignment: .bottom) {
                            if vm.state == .loading {
                                ProgressView()
                                    .padding()
                                    .background(Color.black.opacity(0.4).cornerRadius(8)) 
                            }
                        }
                    case .error(let errorMessage):
                        VStack(alignment: .center, spacing: 16) {
                            Image(systemName: "wifi.exclamationmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64, height: 64)
                            Text(errorMessage)
                            Button {
                                vm.reset()
                            } label: {
                                Text("Retry")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(16)
                        .background(colorScheme == .light ? .black.opacity(0.1) : .white.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .padding(8)
            .navigationTitle("FavFotos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    self.toolbarMenu()
                }
            }
            .searchable(text: $vm.searchTerm)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

extension HomeView {
    func photosView() -> some View {
        CompositionalLayoutView(items: vm.photos, id: \.self, spacing: 8) { photo in
            NavigationLink {
                DetailView(source: .photo(photo))
            } label: {
                GeometryReader { geo in
                    CachedImage(id: photo.id, urlString: photo.url(for: vm.selectedImageQuality)) { phase in
                        switch phase {
                        case .empty, .failure(_):
                            Image(systemName: "photo")
                                .defaultImageModifier()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .cornerRadius(4)
                                .redacted(reason: .placeholder)
                        case .success(let image):
                            let returnedImage = Image(uiImage: image)
                            returnedImage
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
    }
    
    func toolbarMenu() -> some View {
        Menu(content: {
            ForEach(ImageQuality.allCases, id: \.self) { quality in
                Button {
                    vm.updateImageQuality(to: quality)
                } label: {
                    HStack {
                        Text(quality.rawValue)
                        if vm.selectedImageQuality == quality {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }, label: {
            Image(systemName: "gear")
                .tint(.primary)
        })
    }
}

