//
//  AuthService.swift
//  FocusCorner
//
//  Thin async/await wrapper around FirebaseAuth. All Firebase-specific error
//  codes are translated into `AuthError` here so no Firebase type leaks
//  into ViewModels or Views.
//

import Foundation
import FirebaseAuth

@MainActor
final class AuthService {

    static let shared = AuthService()

    private init() {}

    // MARK: - Session state

    var currentUser: User? { Auth.auth().currentUser }
    var isAuthenticated: Bool { Auth.auth().currentUser != nil }

    // MARK: - Auth operations

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func register(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        try await user.delete()
    }

    // MARK: - Error mapping

    func mapError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        guard let code = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown(nsError.localizedDescription)
        }
        switch code {
        case .invalidEmail:         return .invalidEmail
        case .weakPassword:         return .weakPassword
        case .wrongPassword:        return .wrongPassword
        case .userNotFound:         return .userNotFound
        case .emailAlreadyInUse:    return .emailAlreadyInUse
        case .networkError:         return .networkError
        case .requiresRecentLogin:  return .requiresRecentLogin
        default:                    return .unknown(nsError.localizedDescription)
        }
    }
}
