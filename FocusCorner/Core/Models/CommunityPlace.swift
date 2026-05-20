//
//  CommunityPlace.swift
//  FocusCorner

import Foundation
import FirebaseFirestore

/// A user-contributed cafe or workspace stored in Firestore.
struct CommunityPlace: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var vibeTags: [String]
    var wifiQuality: String
    var noiseLevel: String
    var comfortLevel: String
    var openingHours: String
    var notes: String
    var contributorId: String
    var contributorEmail: String
    var imageURLs: [String]
    var latitude: Double?
    var longitude: Double?
    var address: String?
    var city: String?
    var createdAt: Date

    init(
        name: String,
        description: String = "",
        vibeTags: [String] = [],
        wifiQuality: String = "Good",
        noiseLevel: String = "Moderate",
        comfortLevel: String = "Cozy",
        openingHours: String = "",
        notes: String = "",
        contributorId: String,
        contributorEmail: String,
        imageURLs: [String] = [],
        latitude: Double? = nil,
        longitude: Double? = nil,
        address: String? = nil,
        city: String? = nil
    ) {
        self.name = name
        self.description = description
        self.vibeTags = vibeTags
        self.wifiQuality = wifiQuality
        self.noiseLevel = noiseLevel
        self.comfortLevel = comfortLevel
        self.openingHours = openingHours
        self.notes = notes
        self.contributorId = contributorId
        self.contributorEmail = contributorEmail
        self.imageURLs = imageURLs
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.city = city
        self.createdAt = Date()
    }

    var locationLabel: String {
        [address, city].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
    }

    var displayCity: String {
        city ?? address ?? "Turkey"
    }
}
