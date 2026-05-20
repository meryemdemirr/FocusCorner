//
//  AppColors.swift
//  FocusCorner
//
//  Warm, cozy palette inspired by cream, beige and coffee tones.
//

import SwiftUI

enum AppColors {

    static let creamBackground = Color(red: 0.984, green: 0.961, blue: 0.929)   // #FBF5ED
    /// Slightly deeper beige — used for card surfaces and floating panels.
    static let beigeSurface = Color(red: 0.953, green: 0.910, blue: 0.847)     // #F3E8D8
    /// Sand tone — used for subtle dividers and inactive states.
    static let warmSand = Color(red: 0.910, green: 0.851, blue: 0.769)         // #E8D9C4

    // MARK: - Accents
    /// Deep coffee brown — primary brand & text accent.
    static let coffeeBrown = Color(red: 0.388, green: 0.275, blue: 0.196)      // #634632
    /// Warm caramel — primary CTA fill.
    static let caramel = Color(red: 0.792, green: 0.561, blue: 0.376)          // #CA8F60
    /// Lighter caramel — used as the top of CTA gradients and highlights.
    static let lightCaramel = Color(red: 0.886, green: 0.722, blue: 0.553)     // #E2B88D

    // MARK: - Text
    static let textPrimary = Color(red: 0.220, green: 0.157, blue: 0.110)      // #38281C
    static let textSecondary = Color(red: 0.443, green: 0.353, blue: 0.275)    // #715A46
    static let textOnAccent = Color(red: 0.996, green: 0.973, blue: 0.949)     // #FEF8F2

    // MARK: - Gradients
    static let backgroundGradient = LinearGradient(
        colors: [creamBackground, beigeSurface],
        startPoint: .top,
        endPoint: .bottom
    )

    static let caramelGradient = LinearGradient(
        colors: [lightCaramel, caramel],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.55),
            beigeSurface.opacity(0.85)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
