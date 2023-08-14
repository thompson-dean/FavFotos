//
//  CachedImage.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/10.
//

import SwiftUI

enum ImagePhase {
    case empty
    case failure(Error)
    case success(UIImage)
}

struct CachedImage<Content: View>: View {
    
    @StateObject private var manager = CachedImageManager()
    let urlString: String
    @ViewBuilder let content: (ImagePhase) -> Content
    
    var body: some View {
        ZStack {
            switch manager.state {
            case .loading:
                content(.empty)
            case .failed(let error):
                content(.failure(error))
            case .success(let data):
                if let image = UIImage(data: data) {
                    content(.success(image))
                } else {
                    content(.failure(CachedImageError.invalidData))
                }
            default:
                content(.empty)
            }
        }
        .onAppear {
            manager.load(urlString)
        }
    }
}

struct CachedImage_Previews: PreviewProvider {
    static var previews: some View {
        CachedImage(urlString: "https://images.pexels.com/photos/3573351/pexels-photo-3573351.png?auto=compress&cs=tinysrgb&h=650&w=940") { _ in
            EmptyView()
        }
    }
}

extension CachedImage {
    enum CachedImageError: Error {
        case invalidData
    }
}
