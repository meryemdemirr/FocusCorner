//
//  SavedViewModel.swift
//  FocusCorner

import SwiftUI
import Observation

@MainActor
@Observable
final class SavedViewModel {

    private let placeStore = PlaceStore.shared

    // Derived from PlaceStore — observation chain tracks savedPlaceIDs + communityPlaces.
    var savedPlaces: [CommunityPlace] { placeStore.savedPlaces }
    var isLoading: Bool { placeStore.isLoading }

    func removeSaved(_ place: CommunityPlace) {
        Task { await placeStore.toggleSave(place) }
    }
}
