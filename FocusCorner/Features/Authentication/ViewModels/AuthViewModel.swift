//
//  AuthViewModel.swift  →  AuthStateViewModel
//  FocusCorner
//
//  Reactive view-model that reflects the current Firebase user session.
//  Feature screens (e.g. ProfileView) use this to read user info without
//  importing FirebaseAuth directly.
//

import SwiftUI
import Observation
import FirebaseAuth

@MainActor
@Observable
final class AuthStateViewModel {

    // MARK: - Published user state

    var currentUserEmail: String? = Auth.auth().currentUser?.email
    var currentUserUID: String?   = Auth.auth().currentUser?.uid
    var isAuthenticated: Bool     = Auth.auth().currentUser != nil

    // MARK: - Listener

    @ObservationIgnored
    private var listenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                self?.currentUserEmail = user?.email
                self?.currentUserUID   = user?.uid
                self?.isAuthenticated  = user != nil
            }
        }
    }

    deinit {
        if let handle = listenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
