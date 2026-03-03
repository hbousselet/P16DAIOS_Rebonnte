//
//  AuthentificatorMock.swift
//  MediStockTests
//
//  Created by Hugues BOUSSELET on 15/02/2026.
//

import Foundation
import FirebaseAuth
import Firebase
@testable import MediStock

final class AuthenticatorMock: AuthFirebaseProtocol {
    var user: MediStock.User? = nil
    var shouldSuccess: Bool = true
    
    func signUp(email: String, password: String) async throws {
        if shouldSuccess {
            let uid = "bmabe"
            user = MediStock.User(uid: uid, email: email)
        } else {
            throw MedistockError.signUpError("Not able to sign up.")
        }
    }
    
    func signOut() throws {
        if shouldSuccess {
            user = nil
        } else {
            throw MedistockError.signOutError("Not able to sign out.")
        }
    }

    func signIn(email: String, password: String) async throws {
        if shouldSuccess {
            user = MediStock.User(uid: "randommmm22", email: email)
        } else {
            throw MedistockError.signInError("Not able to sign in.")
        }
    }
}
