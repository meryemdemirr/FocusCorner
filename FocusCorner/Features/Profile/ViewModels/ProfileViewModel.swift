//
//  ProfileViewModel.swift
//  FocusCorner

import SwiftUI
import Observation
import FirebaseAuth

@MainActor
@Observable
final class ProfileViewModel {

    private let placeStore = PlaceStore.shared

    // MARK: - Current user (read from Firebase Auth directly)

    var currentUserEmail: String? { Auth.auth().currentUser?.email }
    var currentUserUID: String? { Auth.auth().currentUser?.uid }

    // MARK: - Derived collections

    var contributions: [CommunityPlace] {
        guard let uid = currentUserUID else { return [] }
        return placeStore.myContributions(uid: uid)
    }

    var savedPlaces: [CommunityPlace] { placeStore.savedPlaces }

    // MARK: - Actions

    func deleteContribution(_ place: CommunityPlace) {
        Task { try? await placeStore.deletePlace(place) }
    }

    func removeSaved(_ place: CommunityPlace) {
        Task { await placeStore.toggleSave(place) }
    }
}
