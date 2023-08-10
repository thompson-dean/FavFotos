//
//  NetworkError.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/10.
//

import Foundation

enum NetworkingError: LocalizedError {
    case badURLResponse(url: URL)
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case unknown
    case urlError(URLError)
    
    var errorDescription: String? {
        switch self {
        case .badURLResponse(url: let url): return "Bad response from URL: \(url)"
        case .badRequest: return "Bad request"
        case .unauthorized: return "Unauthorized request"
        case .forbidden: return "Forbidden"
        case .notFound: return "Resource not found"
        case .serverError: return "Internal server error"
        case .unknown: return "Unknown error occurred"
        case .urlError(let error): return error.localizedDescription
        }
    }
}
