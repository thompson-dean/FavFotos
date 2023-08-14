//
//  Photo.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/05.
//

import Foundation

struct Photo: Codable, Identifiable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let photographer: String
    let photographerURL: String
    let photographerID: Int
    let avgColor: String
    let src: Src
    let liked: Bool
    let alt: String
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, url, photographer, src, liked, alt
        case photographerURL = "photographer_url"
        case photographerID = "photographer_id"
        case avgColor = "avg_color"
    }
}

struct Src: Codable, Equatable, Hashable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String
    let landscape: String
    let tiny: String

    enum CodingKeys: String, CodingKey {
        case original, large2x, large, medium, small, portrait, landscape, tiny
    }
}

struct PexelsResponse: Codable {
    let page: Int
    let perPage: Int
    let photos: [Photo]
    let nextPage: String?

    enum CodingKeys: String, CodingKey {
        case page, perPage = "per_page", photos, nextPage = "next_page"
    }
}

extension Photo: Hashable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id &&
               lhs.width == rhs.width &&
               lhs.height == rhs.height &&
               lhs.url == rhs.url &&
               lhs.photographer == rhs.photographer &&
               lhs.photographerURL == rhs.photographerURL &&
               lhs.photographerID == rhs.photographerID &&
               lhs.avgColor == rhs.avgColor &&
               lhs.src == rhs.src &&
               lhs.liked == rhs.liked &&
               lhs.alt == rhs.alt
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(url)
        hasher.combine(photographer)
        hasher.combine(photographerURL)
        hasher.combine(photographerID)
        hasher.combine(avgColor)
        hasher.combine(src)
        hasher.combine(liked)
        hasher.combine(alt)
    }
}
