//
//  AuthentificationViewModel.swift
//  MediStock
//
//  Created by Hugues BOUSSELET on 07/02/2026.
//

import Foundation

@Observable class AuthentificationViewModel {
    var email: String = ""
    var password: String = ""
    var alertIsPresented: Bool = false
    var alert: String?

    let authService: any AuthFirebaseProtocol

    init(sessionStore: AuthFirebaseProtocol = SessionStoreService()) {
        self.authService = sessionStore
    }

    func signIn() async {
        guard isValidEmail(email) else {
            alertIsPresented = true
            alert = MedistockError.invalidEmail.errorDescription
            return
        }

        guard !password.isEmpty else {
            alertIsPresented = true
            alert = MedistockError.emptyPassword.errorDescription
            return
        }
        do {
            _ = try await authService.signIn(email: email, password: password)
        } catch {
            alertIsPresented = true
            alert = (error as? MedistockError)?.errorDescription
        }
    }

    func signUp() async {
        do {
            guard isValidEmail(email) else {
                alertIsPresented = true
                alert = MedistockError.invalidEmail.errorDescription
                return
            }
            guard !password.isEmpty else {
                alertIsPresented = true
                alert = MedistockError.emptyPassword.errorDescription
                return
            }
            _ = try await authService.signUp(email: email, password: password)
        } catch {
            alertIsPresented = true
            alert = (error as? MedistockError)?.errorDescription
        }
    }

    func signOut() {
        do {
            _ = try authService.signOut()
        } catch {
            alertIsPresented = true
            alert = (error as? MedistockError)?.errorDescription
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        guard !email.isEmpty else { return false }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
