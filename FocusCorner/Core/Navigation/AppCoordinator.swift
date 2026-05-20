//
//  AppCoordinator.swift
//  FocusCorner
//
//  Owns the top-level app flow and the (currently simulated) authentication
//  state. Designed to be swapped for a real auth service / Firebase later
//  without touching the views that observe it.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class AppCoordinator {

    // MARK: - Flow

    private(set) var flow: AppFlow = .splash

    // MARK: - Persisted state

    /// Mirrors the same key used by the onboarding flow.
    @ObservationIgnored
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    /// Simulated authentication. Replace with Firebase auth state later.
    @ObservationIgnored
    @AppStorage("isAuthenticated") private var isAuthenticated: Bool = false

    // MARK: - Splash → next stage

    /// Called by SplashView once its intro animation finishes. Decides what
    /// the user should see next based on persisted state.
    func handleSplashFinished() {
        advanceToInitialDestination()
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        hasCompletedOnboarding = true
        transition(to: isAuthenticated ? .main : .authentication)
    }

    // MARK: - Authentication (simulated)

    /// Stand-in for a real sign-in / sign-up call. Flips the persisted flag
    /// and moves the user into the main tab experience.
    func signInSimulated() {
        isAuthenticated = true
        transition(to: .main)
    }

    func signOut() {
        isAuthenticated = false
        transition(to: .authentication)
    }

    // MARK: - Private

    private func advanceToInitialDestination() {
        let next: AppFlow
        if !hasCompletedOnboarding {
            next = .onboarding
        } else if !isAuthenticated {
            next = .authentication
        } else {
            next = .main
        }
        transition(to: next)
    }

    private func transition(to next: AppFlow) {
        guard next != flow else { return }
        withAnimation(.easeInOut(duration: 0.45)) {
            flow = next
        }
    }
}
