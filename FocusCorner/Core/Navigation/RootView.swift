//
//  RootView.swift
//  FocusCorner
//
//  Renders the correct top-level stage of the app based on AppCoordinator.flow.
//  Navigation after sign-in / sign-out is driven automatically by
//  AppCoordinator's Firebase auth-state listener.
//

import SwiftUI

struct RootView: View {

    @State private var coordinator = AppCoordinator()

    var body: some View {
        ZStack {
            switch coordinator.flow {
            case .splash:
                SplashView(onFinished: coordinator.handleSplashFinished)
                    .transition(.opacity)

            case .onboarding:
                OnboardingView(
                    viewModel: OnboardingViewModel(
                        onFinish: coordinator.completeOnboarding
                    )
                )
                .transition(.opacity)

            case .authentication:
                // Navigation after auth succeeds is driven by the
                // Firebase auth-state listener in AppCoordinator.
                AuthView()
                    .transition(.opacity)

            case .main:
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: coordinator.flow)
        .environment(coordinator)
    }
}

#Preview {
    RootView()
}
