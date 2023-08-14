//
//  ErrorHandler.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/13.
//

import Foundation

class ErrorHandler {
    
    static func userFriendlyMessage(from error: Error) -> String {
        switch error {
        case NetworkingError.clientError(let message):
            return !message.isEmpty ? message : "There was a problem processing your request. Please check and try again."
        case NetworkingError.serverError(let message):
            return !message.isEmpty ? message : "Our servers are currently facing an issue. Please try again later."
        case NetworkingError.urlError(let error):
            return error.localizedDescription
        case NetworkingError.unknown:
            return "Unknown error occurred"
        case URLConstructionError.invalidEndpoint:
            return "Invalid endpoint"
        case URLConstructionError.invalidParameters:
            return "Invalid parameters"
        default:
            return "An unexpected error occurred. Please try again."
        }
    }
}
