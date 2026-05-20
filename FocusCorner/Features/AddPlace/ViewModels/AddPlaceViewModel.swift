//
//  AddPlaceViewModel.swift
//  FocusCorner

import SwiftUI
import Observation
import PhotosUI
import UIKit
import FirebaseAuth

@MainActor
@Observable
final class AddPlaceViewModel {

    // MARK: - Search

    var searchText = ""
    var suggestions: [PlaceSearchSuggestion] = []
    var selectedPlace: PlaceSearchResult?

    // MARK: - Form fields

    var placeName = ""
    var description = ""
    var vibeTags = ""
    var wifiQuality = "Good"
    var noiseLevel = "Moderate"
    var comfortLevel = "Cozy"
    var openingHours = ""
    var notes = ""

    // MARK: - Photos

    var selectedImages: [UIImage] = []
    var selectedPhotoItems: [PhotosPickerItem] = []

    // MARK: - Submission state

    var isSubmitting = false
    var showSuccessFeedback = false
    var errorMessage: String?

    // MARK: - Private

    @ObservationIgnored private let searchService = PlaceSearchService()
    @ObservationIgnored private let placeStore = PlaceStore.shared
    @ObservationIgnored private var task: Task<Void, Never>?

    init() {
        searchService.onSuggestionsChanged = { [weak self] suggestions in
            self?.suggestions = suggestions
        }
    }

    // MARK: - Search

    func updateSearchText(_ text: String) {
        searchText = text
        searchService.updateQuery(text)
    }

    func selectSuggestion(_ suggestion: PlaceSearchSuggestion) {
        task?.cancel()
        task = Task { [weak self] in
            guard let self else { return }
            guard let result = await searchService.select(suggestion) else { return }
            selectedPlace = result
            searchText = result.name
            if placeName.isEmpty { placeName = result.name }
            suggestions = []
        }
    }

    // MARK: - Photos

    func addCameraImage(_ image: UIImage) {
        guard selectedImages.count < 5 else { return }
        selectedImages.append(image)
    }

    func loadSelectedPhotos() {
        let items = selectedPhotoItems
        task = Task { [weak self] in
            guard let self else { return }
            var images: [UIImage] = []
            for item in items.prefix(5) {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    images.append(image)
                }
            }
            selectedImages = Array((selectedImages + images).prefix(5))
            selectedPhotoItems = []
        }
    }

    // MARK: - Submit

    func submitContribution() {
        let trimmedName = placeName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter a place name."
            return
        }
        guard let uid = Auth.auth().currentUser?.uid,
              let email = Auth.auth().currentUser?.email else {
            errorMessage = "You must be signed in to add a place."
            return
        }

        let tags = vibeTags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let place = CommunityPlace(
            name: trimmedName,
            description: description,
            vibeTags: tags,
            wifiQuality: wifiQuality,
            noiseLevel: noiseLevel,
            comfortLevel: comfortLevel,
            openingHours: openingHours,
            notes: notes,
            contributorId: uid,
            contributorEmail: email,
            latitude: selectedPlace?.coordinate.latitude,
            longitude: selectedPlace?.coordinate.longitude,
            address: selectedPlace?.street,
            city: selectedPlace?.city
        )

        let images = selectedImages

        task = Task { [weak self] in
            guard let self else { return }
            isSubmitting = true
            errorMessage = nil
            do {
                try await placeStore.addPlace(place, images: images)
                isSubmitting = false
                showSuccessFeedback = true
                resetForm()
                try? await Task.sleep(for: .seconds(2.5))
                showSuccessFeedback = false
            } catch {
                isSubmitting = false
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Reset

    private func resetForm() {
        placeName = ""
        description = ""
        vibeTags = ""
        wifiQuality = "Good"
        noiseLevel = "Moderate"
        comfortLevel = "Cozy"
        openingHours = ""
        notes = ""
        selectedImages = []
        selectedPhotoItems = []
        selectedPlace = nil
        searchText = ""
        suggestions = []
    }
}
