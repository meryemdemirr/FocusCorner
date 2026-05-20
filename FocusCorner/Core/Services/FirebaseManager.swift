//
//  FirebaseManager.swift
//  FocusCorner
//
//  Single-entry-point for all Firebase service references. Call
//  `FirebaseManager.shared.configure()` once from `FocusCornerApp.init()`.
//  Other services (Firestore, Storage, Analytics) are pre-wired here so
//  feature layers can reach them without importing FirebaseCore directly.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class FirebaseManager {

    static let shared = FirebaseManager()

    private(set) var isConfigured = false

    private init() {}

    // MARK: - Setup

    func configure() {
        guard !isConfigured else { return }
        FirebaseApp.configure()
        isConfigured = true
    }

    // MARK: - Service accessors

    var auth: Auth           { Auth.auth() }
    var firestore: Firestore { Firestore.firestore() }
    var storage: Storage     { Storage.storage() }
}
