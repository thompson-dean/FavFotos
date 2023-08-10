//
//  DetailView.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/10.
//

import SwiftUI

struct DetailView: View {
    let photo: Photo
    var body: some View {
        VStack(alignment: .center) {
            CachedImage(urlString: photo.src.large) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case.failure(let error):
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                default:
                    EmptyView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 0)
    }
}
