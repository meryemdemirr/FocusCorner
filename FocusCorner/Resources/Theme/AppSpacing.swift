//
//  AppSpacing.swift
//  FocusCorner
//
//  Centralised spacing & radius scale to keep layouts consistent.
//

import CoreGraphics

enum AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum AppRadius {
    static let sm: CGFloat = 12
    static let md: CGFloat = 20
    static let lg: CGFloat = 28
    static let xl: CGFloat = 36
    static let pill: CGFloat = 999
}

enum AppShadow {
    static let softRadius: CGFloat = 18
    static let softYOffset: CGFloat = 8
    static let softOpacity: Double = 0.08
}
