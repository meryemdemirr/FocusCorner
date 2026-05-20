//
//  L10n.swift
//  FocusCorner
//
//  Centralised, type-safe localisation keys. Every user-facing string lives
//  here so the UI can be translated by adding new entries to the .strings
//  files without touching any views.
//

import SwiftUI

enum L10n {

    // MARK: - Onboarding

    enum Onboarding {
        enum Page1 {
            static let title: LocalizedStringKey       = "onboarding.page1.title"
            static let description: LocalizedStringKey = "onboarding.page1.description"
        }
        enum Page2 {
            static let title: LocalizedStringKey       = "onboarding.page2.title"
            static let description: LocalizedStringKey = "onboarding.page2.description"
        }
        enum Page3 {
            static let title: LocalizedStringKey       = "onboarding.page3.title"
            static let description: LocalizedStringKey = "onboarding.page3.description"
        }
        enum Actions {
            static let skip: LocalizedStringKey        = "onboarding.action.skip"
            static let next: LocalizedStringKey        = "onboarding.action.next"
            static let getStarted: LocalizedStringKey  = "onboarding.action.getStarted"
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

    // MARK: - Authentication

    enum Auth {
        // Mode picker
        static let modeLogin: LocalizedStringKey    = "auth.mode.login"
        static let modeRegister: LocalizedStringKey = "auth.mode.register"

        // Headers
        static let loginTitle: LocalizedStringKey      = "auth.login.title"
        static let loginSubtitle: LocalizedStringKey   = "auth.login.subtitle"
        static let registerTitle: LocalizedStringKey   = "auth.register.title"
        static let registerSubtitle: LocalizedStringKey = "auth.register.subtitle"

        // Fields
        static let emailPlaceholder: LocalizedStringKey           = "auth.field.email"
        static let passwordPlaceholder: LocalizedStringKey        = "auth.field.password"
        static let confirmPasswordPlaceholder: LocalizedStringKey = "auth.field.confirmPassword"

        // Buttons
        static let loginButton: LocalizedStringKey    = "auth.button.login"
        static let registerButton: LocalizedStringKey = "auth.button.register"

        // Legacy keys (kept for source compat)
        static let title: LocalizedStringKey           = "auth.login.title"
        static let subtitle: LocalizedStringKey        = "auth.login.subtitle"
        static let continueButton: LocalizedStringKey  = "auth.button.login"
        static let placeholderNotice: LocalizedStringKey = "auth.login.subtitle"

        // Errors
        enum Error {
            static let defaultTitle: LocalizedStringKey  = "auth.error.title.default"
            static let networkTitle: LocalizedStringKey  = "auth.error.title.network"
            static let invalidEmail: LocalizedStringKey  = "auth.error.invalidEmail"
            static let weakPassword: LocalizedStringKey  = "auth.error.weakPassword"
            static let wrongPassword: LocalizedStringKey = "auth.error.wrongPassword"
            static let userNotFound: LocalizedStringKey  = "auth.error.userNotFound"
            static let emailInUse: LocalizedStringKey    = "auth.error.emailAlreadyInUse"
            static let mismatch: LocalizedStringKey      = "auth.error.passwordMismatch"
            static let network: LocalizedStringKey       = "auth.error.networkError"
            static let recentLogin: LocalizedStringKey   = "auth.error.requiresRecentLogin"
            static let unknown: LocalizedStringKey       = "auth.error.unknown"
        }
    }

    // MARK: - Tabs

    enum Tabs {
        static let home: LocalizedStringKey     = "tabs.home"
        static let map: LocalizedStringKey      = "tabs.map"
        static let addPlace: LocalizedStringKey = "tabs.addPlace"
        static let saved: LocalizedStringKey    = "tabs.saved"
        static let profile: LocalizedStringKey  = "tabs.profile"
    }

    // MARK: - Home

    enum Home {
        static let title: LocalizedStringKey       = "home.title"
        static let subtitle: LocalizedStringKey    = "home.subtitle"
        static let placeholder: LocalizedStringKey = "home.placeholder"
    }

    // MARK: - Map

    enum Map {
        static let title: LocalizedStringKey       = "map.title"
        static let subtitle: LocalizedStringKey    = "map.subtitle"
        static let placeholder: LocalizedStringKey = "map.placeholder"
    }

    // MARK: - AddPlace

    enum AddPlace {
        static let title: LocalizedStringKey       = "addPlace.title"
        static let subtitle: LocalizedStringKey    = "addPlace.subtitle"
        static let placeholder: LocalizedStringKey = "addPlace.placeholder"
    }

    // MARK: - Saved

    enum Saved {
        static let title: LocalizedStringKey       = "saved.title"
        static let subtitle: LocalizedStringKey    = "saved.subtitle"
        static let placeholder: LocalizedStringKey = "saved.placeholder"
    }

    // MARK: - Profile

    enum Profile {
        static let title: LocalizedStringKey            = "profile.title"
        static let subtitle: LocalizedStringKey         = "profile.subtitle"
        static let placeholder: LocalizedStringKey      = "profile.placeholder"
        static let memberLabel: LocalizedStringKey      = "profile.memberLabel"
        static let signOut: LocalizedStringKey          = "profile.signOut"
        static let signOutConfirmTitle: LocalizedStringKey = "profile.signOut.confirmTitle"
        static let deleteAccount: LocalizedStringKey    = "profile.deleteAccount"
        static let deletingAccount: LocalizedStringKey  = "profile.deletingAccount"
        static let deleteConfirmTitle: LocalizedStringKey   = "profile.delete.confirmTitle"
        static let deleteConfirmMessage: LocalizedStringKey = "profile.delete.confirmMessage"
    }

    // MARK: - Common

    enum Common {
        static let cancel: LocalizedStringKey = "common.cancel"
        static let ok: LocalizedStringKey     = "common.ok"
    }
}
