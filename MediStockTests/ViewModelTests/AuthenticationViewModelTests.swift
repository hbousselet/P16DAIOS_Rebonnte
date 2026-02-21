//
//  AuthenticationViewModelTests.swift
//  MediStockTests
//
//  Created by Hugues BOUSSELET on 15/02/2026.
//

import Testing
@testable import MediStock

struct AuthenticationViewModelTests {
    let authService = AuthenticatorMock()

    @Test func signInOk() async throws {
        let email: String = "test@test.com"
        var password: String = "Tdhh123!"
        authService.shouldSuccess = true
        let viewModel = AuthentificationViewModel(sessionStore: authService)
        viewModel.email = email
        viewModel.password = password
        await viewModel.signIn()
        #expect(authService.user?.email == email)
    }

    @Test func signNOkInvalidEmail() async throws {
        let email: String = "testtest"
        var password: String = "Tdhh123!"
        authService.shouldSuccess = false
        let viewModel = AuthentificationViewModel(sessionStore: authService)
        viewModel.email = email
        viewModel.password = password
        await viewModel.signIn()
        #expect(viewModel.alertIsPresented)
        #expect(viewModel.alert == MedistockError.invalidEmail.errorDescription)
    }

    @Test func signInNOkEmptyPassword() async throws {
        let email: String = "testtest@gmail.com"
        var password: String = ""
        authService.shouldSuccess = false
        let viewModel = AuthentificationViewModel(sessionStore: authService)
        viewModel.email = email
        viewModel.password = password
        await viewModel.signIn()
        #expect(viewModel.alertIsPresented)
        #expect(viewModel.alert == MedistockError.emptyPassword.errorDescription)
    }

    @Test func signInNOk() async throws {
        let email: String = "test@test.com"
        var password: String = "Tdhh123!"
        authService.shouldSuccess = false
        let viewModel = AuthentificationViewModel(sessionStore: authService)
        viewModel.email = email
        viewModel.password = password
        await viewModel.signIn()
        #expect(viewModel.alertIsPresented)
        #expect(viewModel.alert == MedistockError.signInError("Not able to sign in.").errorDescription)
    }

    @Test func signUpOk() async throws {
        let email: String = "test@test.com"
        var password: String = "Tdhh123!"
        authService.shouldSuccess = true
        let viewModel = AuthentificationViewModel(sessionStore: authService)
        viewModel.email = email
        viewModel.password = password
        await viewModel.signUp()
        #expect(authService.user?.email == email)
    }

    @Test func signUpNOkInvalidEmail() async throws {
        let email: String = "testtest"
        var password: String = "Tdhh123!"
        authService.shouldSuccess = false
        let viewModel = AuthentificationViewModel(sessionStore: authService)
        viewModel.email = email
        viewModel.password = password
        await viewModel.signUp()
        #expect(viewModel.alertIsPresented)
        #expect(viewModel.alert == MedistockError.invalidEmail.errorDescription)
    }

    @Test func signUpNOkEmptyPassword() async throws {
        let email: String = "testtest@gmail.com"
        var password: String = ""
        authService.shouldSuccess = false
        let viewModel = AuthentificationViewModel(sessionStore: authService)
        viewModel.email = email
        viewModel.password = password
        await viewModel.signUp()
        #expect(viewModel.alertIsPresented)
        #expect(viewModel.alert == MedistockError.emptyPassword.errorDescription)
    }

    @Test func signUpNOk() async throws {
        let email: String = "test@test.com"
        var password: String = "Tdhh123!"
        authService.shouldSuccess = false
        let viewModel = AuthentificationViewModel(sessionStore: authService)
        viewModel.email = email
        viewModel.password = password
        await viewModel.signUp()
        #expect(viewModel.alertIsPresented)
        #expect(viewModel.alert == MedistockError.signUpError("Not able to sign up.").errorDescription)
    }

    @Test func signOutOk() async throws {
        let email: String = "test@test.com"
        var uid: String = "hbdsjhHHDVHVZKJDi5267HUIJ"
        authService.shouldSuccess = true
        authService.user = User(uid: email, email: uid)
        let viewModel = AuthentificationViewModel(sessionStore: authService)
        viewModel.signOut()
        #expect(authService.user == nil)
    }

    @Test func signOutNOk() async throws {
        let email: String = "test@test.com"
        var uid: String = "hbdsjhHHDVHVZKJDi5267HUIJ"
        authService.shouldSuccess = false
        authService.user = User(uid: email, email: uid)
        let viewModel = AuthentificationViewModel(sessionStore: authService)
        viewModel.signOut()
        #expect(viewModel.alertIsPresented)
        #expect(viewModel.alert == MedistockError.signOutError("Not able to sign out.").errorDescription)
    }
}
