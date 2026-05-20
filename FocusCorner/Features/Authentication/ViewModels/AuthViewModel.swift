//
//  AuthViewModel.swift
//  FocusCorner
//
//  Placeholder authentication view model. No real auth logic — exposes a
//  single `continue` action that the coordinator handles. This is the seam
//  where Firebase Auth will be wired in later.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class AuthViewModel {

    var isWorking: Bool = false

    /// Pretend the user signed in successfully. Coordinator handles the
    /// real transition.
    func handleContinue(onSuccess: @escaping () -> Void) async {
        guard !isWorking else { return }
        isWorking = true
        // Tiny artificial delay so the button transition feels intentional.
        try? await Task.sleep(for: .milliseconds(450))
        isWorking = false
        onSuccess()
    }
}
