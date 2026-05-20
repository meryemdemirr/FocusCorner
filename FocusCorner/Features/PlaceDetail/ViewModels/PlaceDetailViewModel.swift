//
//  PlaceDetailViewModel.swift
//  FocusCorner

import SwiftUI
import Observation

@MainActor
@Observable
final class PlaceDetailViewModel {

    private(set) var place: CommunityPlace
    private let placeStore = PlaceStore.shared

    // Computed from PlaceStore — SwiftUI observation chain tracks savedPlaceIDs changes.
    var isSaved: Bool { placeStore.isSaved(place) }

    init(place: CommunityPlace) {
        self.place = place
    }

    func toggleSave() {
        Task { await placeStore.toggleSave(place) }
    }
}
