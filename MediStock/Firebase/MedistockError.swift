//
//  MedistockError.swift
//  MediStock
//
//  Created by Hugues BOUSSELET on 13/01/2026.
//

import Foundation

// lokalise error
enum MedistockError: LocalizedError {
    case addListenerError(String)
    case deleteError(String)
    case updateError(String)

    var errorDescription: String? {
        switch self {
        case .addListenerError(let message): return "Error when fetching the content in db with message: \(message)"
        case .updateError(let message): return "Error when updating the content in db with message: \(message)"
        case .deleteError(let message): return "Error when deleting the content in db with message: \(message)"
        }
    }
}
