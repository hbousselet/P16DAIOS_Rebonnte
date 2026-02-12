import Foundation
import Firebase
import FirebaseAuth

protocol AuthFirebaseProtocol {
    var user: User? { get }
    func listen()
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() throws
}

protocol AuthUserProtocol {
    var uid: String { get }
    var email: String? { get }
}

extension FirebaseAuth.User : AuthUserProtocol {}

@Observable class SessionStoreService: AuthFirebaseProtocol {
    var user: User?
    private var handle: AuthStateDidChangeListenerHandle?
    private var auth = Auth.auth()

    deinit {
        unbind()
    }

    public func listen() {
        handle = auth.addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.user = User(uid: user.uid, email: user.email)
            } else {
                self.user = nil
            }
        }
    }

    public func signIn(email: String, password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw MedistockError.signUpError(error.localizedDescription)
        }
    }

    public func signUp(email: String, password: String) async throws {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            throw MedistockError.signInError(error.localizedDescription)
        }
    }

    public func signOut() throws {
        do {
            try auth.signOut()
            self.user = nil
        } catch {
            throw MedistockError.signOutError(error.localizedDescription)
        }
    }

    private func unbind() {
        if let handle = handle {
            auth.removeStateDidChangeListener(handle)
        }
    }
}

struct User: AuthUserProtocol {
    var uid: String
    var email: String?
}
