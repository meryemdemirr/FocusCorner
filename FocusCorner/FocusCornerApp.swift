//
//  FocusCornerApp.swift
//  FocusCorner
//
//  Created by Meryem Demir on 19.05.2026.
//

import SwiftUI

@main
struct FocusCornerApp: App {

    init() {
        // Configure Firebase before any view initialises so that the
        // auth-state listener in AppCoordinator can attach immediately.
        FirebaseManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
