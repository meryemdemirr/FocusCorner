//
//  RegisterViewModel.swift
//  FocusCorner
//
//  Manages registration form state including confirm-password matching,
//  client-side validation, and Firebase user creation via AuthService.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class RegisterViewModel {

    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var isLoading: Bool = false
    var authError: AuthError? = nil
    var showError: Bool = false

    // MARK: - Actions

    func register() async {
        guard validateInputs() else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await AuthService.shared.register(
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
        guard password.count >= 6 else {
            authError = .weakPassword
            showError = true
            return false
        }
        guard password == confirmPassword else {
            authError = .passwordMismatch
            showError = true
            return false
        }
        return true
    }
}
