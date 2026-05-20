//
//  AppTypography.swift
//  FocusCorner
//
//  Premium, Apple-inspired type scale built on the system font with rounded design.
//

import SwiftUI

enum AppTypography {

    /// Large display title used on hero sections.
    static let display = Font.system(size: 34, weight: .bold, design: .rounded)
    /// Title used on onboarding cards.
    static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
    /// Section / card subtitle.
    static let subtitle = Font.system(size: 18, weight: .medium, design: .rounded)
    /// Long-form body copy.
    static let body = Font.system(size: 16, weight: .regular, design: .rounded)
    /// Buttons and emphasised labels.
    static let button = Font.system(size: 17, weight: .semibold, design: .rounded)
    /// Captions, small hints.
    static let caption = Font.system(size: 13, weight: .regular, design: .rounded)
}
