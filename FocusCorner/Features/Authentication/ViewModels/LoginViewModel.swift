//
//  LoginViewModel.swift
//  FocusCorner
//
//  Manages login form state, client-side validation, and delegates
//  the actual sign-in call to AuthService. Navigation after a
//  successful login is driven automatically by AppCoordinator's
//  Firebase auth-state listener — no callback needed here.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class LoginViewModel {

    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var authError: AuthError? = nil
    var showError: Bool = false

    // MARK: - Actions

    func login() async {
        guard validateInputs() else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await AuthService.shared.signIn(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
        } catch {
            authError = AuthService.shared.mapError(error)
            showError = true
        }
    }

    func clearError() {
        authError = nil
        showError = false
    }

    // MARK: - Validation

    private func validateInputs() -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.contains("@"), trimmed.contains(".") else {
            authError = .invalidEmail
            showError = true
            return false
        }
        guard !password.isEmpty else {
            authError = .wrongPassword
            showError = true
            return false
        }
        return true
    }
}
