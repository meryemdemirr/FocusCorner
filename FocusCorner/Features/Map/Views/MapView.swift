//
//  MapView.swift
//  FocusCorner
//

import SwiftUI

struct MapView: View {

    @State private var viewModel = MapViewModel()

    var body: some View {
        FeaturePlaceholderScreen(
            symbol: "map.fill",
            title: L10n.Map.title,
            subtitle: L10n.Map.subtitle,
            placeholder: L10n.Map.placeholder
        )
    }
}

#Preview {
    MapView()
}
