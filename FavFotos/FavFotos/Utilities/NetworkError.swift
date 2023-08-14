//
//  NetworkError.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/10.
//

import Foundation

enum NetworkingError: Error {
    case urlError(URLError)
    case serverError(message: String)
    case clientError(message: String)
    case unknown
}
