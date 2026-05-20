//
//  AppFlow.swift
//  FocusCorner
//
//  High-level routing stages of the app. Mutually exclusive — only one stage
//  is on-screen at a time.
//

import Foundation

enum AppFlow: Equatable {
    case splash
    case onboarding
    case authentication
    case main
}
