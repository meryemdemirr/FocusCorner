//
//  HomeViewModel.swift
//  FocusCorner

import SwiftUI
import Observation

@MainActor
@Observable
final class HomeViewModel {

    // MARK: - Search UI state

    var isSearchExpanded = false
    var searchText = ""
    var suggestions: [PlaceSearchSuggestion] = []
    var isSearching = false

    // MARK: - Community places — sourced from PlaceStore

    // Accessing these computed properties during view body rendering
    // establishes SwiftUI observation on PlaceStore's stored properties.
    private let placeStore = PlaceStore.shared

    var communityPlaces: [CommunityPlace] { placeStore.communityPlaces }
    var isLoading: Bool { placeStore.isLoading }

    // MARK: - Private

    @ObservationIgnored private let searchService = PlaceSearchService()
    @ObservationIgnored private var searchTask: Task<Void, Never>?

    init() {
        searchService.onSuggestionsChanged = { [weak self] suggestions in
            self?.suggestions = suggestions
        }
    }

    // MARK: - Search

    func toggleSearch() {
        isSearchExpanded.toggle()
        if !isSearchExpanded { suggestions = [] }
    }

    func updateSearchText(_ text: String) {
        searchText = text
        searchService.updateQuery(text)
        isSearching = searchService.isSearching
    }

    func selectSuggestion(_ suggestion: PlaceSearchSuggestion) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            isSearching = true
            defer { isSearching = false }
            if let result = await searchService.select(suggestion) {
                searchText = result.name
            }
            suggestions = []
        }
    }

    func submitSearch() {
        let text = searchText
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            isSearching = true
            defer { isSearching = false }
            await searchService.search(text: text)
        }
    }
}
