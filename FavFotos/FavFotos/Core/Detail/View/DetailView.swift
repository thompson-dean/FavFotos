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
    let photo: Photo
    @StateObject private var vm = DetailViewModel()
    @State private var isShowingPhotographerLink: Bool = false
    @State private var isShowingPhotoInformation: Bool = false
    
    var body: some View {
        ZStack(alignment: .center) {
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
            buttonViews()
                .onAppear {
                    vm.checkIfPhotoIsLiked(id: photo.id)
                }
        }
        .navigationTitle(photo.photographer)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

extension DetailView {
    func buttonViews() -> some View {
        VStack {
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
                    if let url = URL(string: photo.photographerURL) {
                        SafariWebView(url: url)
                            .ignoresSafeArea()
                    }
                }
                Spacer()
                Button {
                    isShowingPhotoInformation.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.primary)
                        .frame(width: 24, height: 24)
                }
                .sheet(isPresented: $isShowingPhotoInformation) {
                    Text(photo.avgColor)
                        .presentationDetents([.medium])
                }
                Spacer()
                Button {
                    vm.likePhoto(photo: photo)
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
