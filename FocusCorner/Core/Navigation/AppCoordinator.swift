//
//  AppCoordinator.swift
//  FocusCorner
//
//  Owns the top-level app flow. Auth state is driven by a Firebase
//  auth-state listener so navigation updates automatically on sign-in,
//  sign-out, and session restore — no manual flag flipping required.
//

import SwiftUI
import Observation
import FirebaseAuth

@MainActor
@Observable
final class AppCoordinator {

    // MARK: - Flow

    private(set) var flow: AppFlow = .splash
    private(set) var currentUser: User? = nil

    // MARK: - Persisted

    @ObservationIgnored
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    // MARK: - Listener

    @ObservationIgnored
    private var authListenerHandle: AuthStateDidChangeListenerHandle?

    // MARK: - Init / deinit

    init() {
        startAuthListener()
    }

    deinit {
        if let handle = authListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Splash

    /// Called by SplashView when its intro animation finishes.
    /// By this point the Firebase listener has already fired with the
    /// persisted session (or nil), so `currentUser` is already accurate.
    func handleSplashFinished() {
        if !hasCompletedOnboarding {
            transition(to: .onboarding)
        } else if currentUser != nil {
            transition(to: .main)
        } else {
            transition(to: .authentication)
        }
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        hasCompletedOnboarding = true
        transition(to: currentUser != nil ? .main : .authentication)
    }

    // MARK: - Auth

    func signOut() {
        PlaceStore.shared.stopListening()
        do {
            try AuthService.shared.signOut()
            // Listener fires → handleAuthStateChange → transitions to .authentication
        } catch {
            // signOut can only fail if there's no signed-in user — safe to ignore
        }
    }

    // MARK: - Private

    private func startAuthListener() {
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.currentUser = user
                // Only react to auth changes after the splash screen clears.
                if self.flow != .splash {
                    self.handleAuthStateChange(user: user)
                }
            }
        }
    }

    private func handleAuthStateChange(user: User?) {
        if user != nil {
            transition(to: .main)
        } else {
            transition(to: hasCompletedOnboarding ? .authentication : .onboarding)
        }
    }

    private func transition(to next: AppFlow) {
        guard next != flow else { return }
        withAnimation(.easeInOut(duration: 0.45)) {
            flow = next
        }
    }
}
