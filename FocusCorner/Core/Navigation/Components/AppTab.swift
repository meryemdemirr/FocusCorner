//
//  AppTab.swift
//  FocusCorner
//
//  Identifies each tab in the main tab bar and supplies its display metadata.
//

import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable, Hashable {
    case home
    case map
    case addPlace
    case saved
    case profile

    var id: Int { rawValue }

    /// Localised, user-facing title shown under the tab icon.
    var title: LocalizedStringKey {
        switch self {
        case .home:     return L10n.Tabs.home
        case .map:      return L10n.Tabs.map
        case .addPlace: return L10n.Tabs.addPlace
        case .saved:    return L10n.Tabs.saved
        case .profile:  return L10n.Tabs.profile
        }
    }

    var symbol: String {
        switch self {
        case .home:     return "house.fill"
        case .map:      return "map.fill"
        case .addPlace: return "plus"
        case .saved:    return "bookmark.fill"
        case .profile:  return "person.fill"
        }
    }

    /// AddPlace is rendered as a prominent centre action rather than a regular tab.
    var isPrimaryAction: Bool {
        self == .addPlace
    }
}
