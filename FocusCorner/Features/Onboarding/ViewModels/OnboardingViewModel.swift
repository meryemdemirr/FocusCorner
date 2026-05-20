//
//  OnboardingViewModel.swift
//  FocusCorner
//

import SwiftUI
import Observation

/// Drives the onboarding flow: which page is visible, what the CTA should
/// say, and what happens when the user taps Skip / Next / Get Started.
@MainActor
@Observable
final class OnboardingViewModel {

    // MARK: - State

    let pages: [OnboardingPage]
    var currentIndex: Int = 0

    /// Invoked when the user completes (or skips) the onboarding flow.
    /// The hosting view supplies this closure to navigate forward.
    var onFinish: () -> Void

    // MARK: - Init

    init(pages: [OnboardingPage] = OnboardingPage.all,
         onFinish: @escaping () -> Void = {}) {
        self.pages = pages
        self.onFinish = onFinish
    }

    // MARK: - Derived state

    var isLastPage: Bool {
        currentIndex >= pages.count - 1
    }

    var isFirstPage: Bool {
        currentIndex == 0
    }

    var primaryActionTitle: LocalizedStringKey {
        isLastPage ? L10n.Onboarding.Actions.getStarted : L10n.Onboarding.Actions.next
    }

    var showsSkipButton: Bool {
        !isLastPage
    }

    // MARK: - Actions

    func goToNext() {
        guard !isLastPage else {
            finish()
            return
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.85)) {
            currentIndex += 1
        }
    }

    func skip() {
        finish()
    }

    /// Programmatic jump used by the page indicator.
    func go(to index: Int) {
        guard pages.indices.contains(index) else { return }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.85)) {
            currentIndex = index
        }
    }

    // MARK: - Private

    private func finish() {
        onFinish()
    }
}
