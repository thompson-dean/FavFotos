//
//  DetailView.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/10.
//

import SwiftUI
import UIKit



struct DetailView: View {
    
    @Environment(\.dismiss) var dismiss
    let source: DetailSource
    @StateObject private var vm = DetailViewModel()
    @State private var isShowingPhotographerLink: Bool = false
    @State private var isShowingPhotoInformation: Bool = false
    
    var body: some View {
        ZStack(alignment: .center) {
            switch source {
            case .photo(let photo):
                CachedImage(id: photo.id, urlString: photo.src.large) { phase in
                    switch phase {
                    case .empty, .failure(_):
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .success(let image):
                        ImageViewerRepresentable(image: image)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            case .entity(let photoEntity):
                if let data = photoEntity.image, let image = UIImage(data: data) {
                    ImageViewerRepresentable(image: image)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            buttonViews()
                .onAppear {
                    vm.checkIfPhotoIsLiked(source: source)
                }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var title: String {
        switch source {
        case .photo(let photo):
            return photo.photographer
        case .entity(let photoEntity):
            return photoEntity.photographer ?? ""
        }
    }
}

extension DetailView {
    func buttonViews() -> some View {
        let photoData: (photographerURL: String, avgColor: String) = {
            switch source {
            case .photo(let photo):
                return (photo.photographerURL, photo.avgColor)
            case .entity(let photoEntity):
                return (photoEntity.photographerURL ?? "", "")
            }
        }()
        
        return VStack {
            Spacer()
            HStack {
                Button {
                    isShowingPhotographerLink.toggle()
                } label: {
                    Image(systemName: "link")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.primary)
                        .frame(width: 24, height: 24)
                }
                .fullScreenCover(isPresented: $isShowingPhotographerLink) {
                    if let url = URL(string: photoData.photographerURL) {
                        SafariWebView(url: url)
                            .ignoresSafeArea()
                    }
                }
                Spacer()
                Button {
                    vm.likePhoto(source: source)
                } label: {
                    Image(systemName: vm.isPhotoLiked ? "heart.fill" : "heart")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.primary)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(16)
        }
    }
}
