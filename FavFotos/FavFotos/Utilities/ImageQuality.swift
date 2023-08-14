//
//  ImageQuality.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/13.
//

import Foundation

enum ImageQuality: String, CaseIterable {
    case low = "Low Quality"
    case medium = "Medium Quality"
    case high = "High Quality"
    
    var resolutionKey: String {
        switch self {
        case .low:
            return "small"
        case .medium:
            return "medium"
        case .high:
            return "large"
        }
    }
}
