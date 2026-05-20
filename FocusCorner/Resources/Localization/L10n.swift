//
//  L10n.swift
//  FocusCorner
//
//  Centralised, type-safe localisation keys. Every user-facing string lives here
//  so the UI can be translated by adding new entries to the .strings files in
//  the matching .lproj directories (en.lproj, tr.lproj, …) without touching views.
//

import SwiftUI

/// Namespaced wrappers around `LocalizedStringKey` so each feature owns its strings.
enum L10n {

    // MARK: - Onboarding

    enum Onboarding {

        enum Page1 {
            static let title: LocalizedStringKey = "onboarding.page1.title"
            static let description: LocalizedStringKey = "onboarding.page1.description"
        }

        enum Page2 {
            static let title: LocalizedStringKey = "onboarding.page2.title"
            static let description: LocalizedStringKey = "onboarding.page2.description"
        }

        enum Page3 {
            static let title: LocalizedStringKey = "onboarding.page3.title"
            static let description: LocalizedStringKey = "onboarding.page3.description"
        }

        enum Actions {
            static let skip: LocalizedStringKey = "onboarding.action.skip"
            static let next: LocalizedStringKey = "onboarding.action.next"
            static let getStarted: LocalizedStringKey = "onboarding.action.getStarted"
        }

        enum Accessibility {
            static let pageIndicator: LocalizedStringKey = "onboarding.a11y.pageIndicator"
        }
    }

    // MARK: - Splash

    enum Splash {
        static let appName: LocalizedStringKey = "splash.appName"
        static let tagline: LocalizedStringKey = "splash.tagline"
    }

    // MARK: - Authentication (placeholder copy)

    enum Auth {
        static let title: LocalizedStringKey = "auth.title"
        static let subtitle: LocalizedStringKey = "auth.subtitle"
        static let continueButton: LocalizedStringKey = "auth.continue"
        static let placeholderNotice: LocalizedStringKey = "auth.placeholderNotice"
    }

    // MARK: - Tabs

    enum Tabs {
        static let home: LocalizedStringKey = "tabs.home"
        static let map: LocalizedStringKey = "tabs.map"
        static let addPlace: LocalizedStringKey = "tabs.addPlace"
        static let saved: LocalizedStringKey = "tabs.saved"
        static let profile: LocalizedStringKey = "tabs.profile"
    }

    // MARK: - Feature placeholders

    enum Home {
        static let title: LocalizedStringKey = "home.title"
        static let subtitle: LocalizedStringKey = "home.subtitle"
        static let placeholder: LocalizedStringKey = "home.placeholder"
    }

    enum Map {
        static let title: LocalizedStringKey = "map.title"
        static let subtitle: LocalizedStringKey = "map.subtitle"
        static let placeholder: LocalizedStringKey = "map.placeholder"
    }

    enum AddPlace {
        static let title: LocalizedStringKey = "addPlace.title"
        static let subtitle: LocalizedStringKey = "addPlace.subtitle"
        static let placeholder: LocalizedStringKey = "addPlace.placeholder"
    }

    enum Saved {
        static let title: LocalizedStringKey = "saved.title"
        static let subtitle: LocalizedStringKey = "saved.subtitle"
        static let placeholder: LocalizedStringKey = "saved.placeholder"
    }

    enum Profile {
        static let title: LocalizedStringKey = "profile.title"
        static let subtitle: LocalizedStringKey = "profile.subtitle"
        static let placeholder: LocalizedStringKey = "profile.placeholder"
        static let signOut: LocalizedStringKey = "profile.signOut"
    }
}
