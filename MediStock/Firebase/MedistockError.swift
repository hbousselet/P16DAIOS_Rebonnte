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
    case createError(String)
    case getError(String)
    case noUserFound(String)
    case signInError(String)
    case signUpError(String)
    case signOutError(String)
    case emptyAisleName
    case emptyMedicineName
    case noNumberInAisleName
    case emptyStockMedicineCreation
    case alreadyExists
    case invalidEmail
    case invalidPassword
    case emptyPassword




    var errorDescription: String? {
        switch self {
        case .addListenerError(let message): return "Error when fetching the content in db with message: \(message)"
        case .updateError(let message): return "Error when updating the content in db with message: \(message)"
        case .deleteError(let message): return "Error when deleting the content in db with message: \(message)"
        case .createError(let message): return "Error when creating the content in db with message: \(message)"
        case .getError(let message): return "Error when getting the content in db with message: \(message)"
        case .noUserFound(let message): return "No user found with this id: \(message)"
        case .signInError(let message): return "Sign in error with message: \(message)"
        case .signUpError(let message): return "Sign up error with message: \(message)"
        case .signOutError(let message): return "Sign out error with message: \(message)"
        case .emptyAisleName: return "Aisle name cannot be empty"
        case .emptyMedicineName: return "Medicine name cannot be empty"
        case .noNumberInAisleName: return "Aisle name must contain a number"
        case .emptyStockMedicineCreation: return "Stock is empty"
        case .alreadyExists: return "Medicine already exists at that aisle"
        case .invalidEmail: return "Invalid email"
        case .invalidPassword: return "Invalid password"
        case .emptyPassword: return "Password cannot be empty"
        }
    }
}
