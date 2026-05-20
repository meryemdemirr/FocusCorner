//
//  PlaceStore.swift
//  FocusCorner
//
//  Single source of truth for community-added places.
//  Maintains real-time Firestore listeners for both the global
//  places feed and the current user's saved-place IDs.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import UIKit
import Observation

@MainActor
@Observable
final class PlaceStore {

    static let shared = PlaceStore()

    // MARK: - Observable state

    private(set) var communityPlaces: [CommunityPlace] = []
    private(set) var savedPlaceIDs: Set<String> = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Private

    @ObservationIgnored private let db = Firestore.firestore()
    @ObservationIgnored private let storage = Storage.storage()
    @ObservationIgnored private var placesListener: ListenerRegistration?
    @ObservationIgnored private var savedListener: ListenerRegistration?

    private init() {}

    // MARK: - Lifecycle

    func startListening() {
        startPlacesListener()
        if let uid = Auth.auth().currentUser?.uid {
            startSavedListener(uid: uid)
        }
    }

    func stopListening() {
        placesListener?.remove()
        savedListener?.remove()
        placesListener = nil
        savedListener = nil
        communityPlaces = []
        savedPlaceIDs = []
    }

    func refreshSavedListener() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        startSavedListener(uid: uid)
    }

    // MARK: - Real-time listeners

    private func startPlacesListener() {
        placesListener?.remove()
        isLoading = true
        placesListener = db.collection("places")
            .order(by: "createdAt", descending: true)
            .limit(to: 60)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.isLoading = false
                    if let error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    guard let docs = snapshot?.documents else { return }
                    self.communityPlaces = docs.compactMap { try? $0.data(as: CommunityPlace.self) }
                }
            }
    }

    private func startSavedListener(uid: String) {
        savedListener?.remove()
        savedListener = db.collection("users").document(uid)
            .collection("savedPlaces")
            .addSnapshotListener { [weak self] snapshot, _ in
                Task { @MainActor [weak self] in
                    guard let self, let docs = snapshot?.documents else { return }
                    self.savedPlaceIDs = Set(docs.map { $0.documentID })
                }
            }
    }

    // MARK: - Derived collections

    var savedPlaces: [CommunityPlace] {
        communityPlaces.filter { savedPlaceIDs.contains($0.id ?? "") }
    }

    func myContributions(uid: String) -> [CommunityPlace] {
        communityPlaces.filter { $0.contributorId == uid }
    }

    // MARK: - Save / unsave

    func isSaved(_ place: CommunityPlace) -> Bool {
        guard let id = place.id else { return false }
        return savedPlaceIDs.contains(id)
    }

    func toggleSave(_ place: CommunityPlace) async {
        guard let uid = Auth.auth().currentUser?.uid,
              let placeId = place.id else { return }
        let ref = db.collection("users").document(uid)
            .collection("savedPlaces").document(placeId)
        if isSaved(place) {
            try? await ref.delete()
        } else {
            try? await ref.setData(["savedAt": FieldValue.serverTimestamp()])
        }
    }

    // MARK: - Add place

    func addPlace(_ place: CommunityPlace, images: [UIImage]) async throws {
        var mutablePlace = place

        if !images.isEmpty {
            var urls: [String] = []
            for image in images {
                if let url = try? await uploadImage(image) {
                    urls.append(url)
                }
            }
            mutablePlace.imageURLs = urls
        }

        let ref = db.collection("places").document()
        mutablePlace.id = ref.documentID
        try await ref.setData(from: mutablePlace)
    }

    // MARK: - Delete place

    func deletePlace(_ place: CommunityPlace) async throws {
        guard let id = place.id else { return }
        try await db.collection("places").document(id).delete()
    }

    // MARK: - Image upload

    private func uploadImage(_ image: UIImage) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.75) else {
            throw PlaceStoreError.compressionFailed
        }
        let path = "place_images/\(UUID().uuidString).jpg"
        let ref = storage.reference().child(path)
        _ = try await ref.putDataAsync(data)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    enum PlaceStoreError: LocalizedError {
        case compressionFailed
        var errorDescription: String? { "Failed to compress image." }
    }
}
