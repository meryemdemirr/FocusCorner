//
//  OnboardingPage.swift
//  FocusCorner
//

import SwiftUI

/// Static data describing a single onboarding slide.
struct OnboardingPage: Identifiable, Equatable {
    let id: Int
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    /// SF Symbol acting as the placeholder illustration for the slide.
    let symbol: String
    /// Background tint used for the illustration container.
    let accent: Color

    static let all: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            title: L10n.Onboarding.Page1.title,
            description: L10n.Onboarding.Page1.description,
            symbol: "cup.and.saucer.fill",
            accent: AppColors.lightCaramel
        ),
        OnboardingPage(
            id: 1,
            title: L10n.Onboarding.Page2.title,
            description: L10n.Onboarding.Page2.description,
            symbol: "slider.horizontal.3",
            accent: AppColors.warmSand
        ),
        OnboardingPage(
            id: 2,
            title: L10n.Onboarding.Page3.title,
            description: L10n.Onboarding.Page3.description,
            symbol: "heart.circle.fill",
            accent: AppColors.caramel
        )
    ]
}
