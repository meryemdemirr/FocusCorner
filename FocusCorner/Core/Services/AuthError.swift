//
//  AuthError.swift
//  FocusCorner
//
//  Domain error type for every authentication failure. Keeps Firebase error
//  codes out of the view and view-model layers.
//

import Foundation

enum AuthError: Error, LocalizedError, Identifiable, Equatable {

    case invalidEmail
    case weakPassword
    case wrongPassword
    case userNotFound
    case emailAlreadyInUse
    case passwordMismatch
    case networkError
    case requiresRecentLogin
    case unknown(String)

    // MARK: - Identifiable

    var id: String { errorDescription ?? "auth.error.unknown" }

    // MARK: - Equatable

    static func == (lhs: AuthError, rhs: AuthError) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .invalidEmail:        return String(localized: "auth.error.invalidEmail")
        case .weakPassword:        return String(localized: "auth.error.weakPassword")
        case .wrongPassword:       return String(localized: "auth.error.wrongPassword")
        case .userNotFound:        return String(localized: "auth.error.userNotFound")
        case .emailAlreadyInUse:   return String(localized: "auth.error.emailAlreadyInUse")
        case .passwordMismatch:    return String(localized: "auth.error.passwordMismatch")
        case .networkError:        return String(localized: "auth.error.networkError")
        case .requiresRecentLogin: return String(localized: "auth.error.requiresRecentLogin")
        case .unknown(let msg):    return msg.isEmpty ? String(localized: "auth.error.unknown") : msg
        }
    }

    var alertTitle: String {
        switch self {
        case .networkError: return String(localized: "auth.error.title.network")
        default:            return String(localized: "auth.error.title.default")
        }
    }
}
