//
//  Photo+URL.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/13.
//

import SwiftUI

extension Photo {
    func url(for quality: ImageQuality) -> String {
        switch quality {
        case .low:
            return src.small
        case .medium:
            return src.medium
        case .high:
            return src.large
        }
    }
}
