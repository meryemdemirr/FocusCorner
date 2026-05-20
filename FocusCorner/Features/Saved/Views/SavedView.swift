//
//  SavedView.swift
//  FocusCorner
//

import SwiftUI

struct SavedView: View {

    @State private var viewModel = SavedViewModel()

    var body: some View {
        FeaturePlaceholderScreen(
            symbol: "bookmark.fill",
            title: L10n.Saved.title,
            subtitle: L10n.Saved.subtitle,
            placeholder: L10n.Saved.placeholder
        )
    }
}

#Preview {
    SavedView()
}
