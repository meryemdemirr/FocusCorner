//
//  HomeView.swift
//  FocusCorner
//

import SwiftUI

struct HomeView: View {

    @State private var viewModel = HomeViewModel()

    var body: some View {
        FeaturePlaceholderScreen(
            symbol: "sun.horizon.fill",
            title: L10n.Home.title,
            subtitle: L10n.Home.subtitle,
            placeholder: L10n.Home.placeholder
        )
    }
}

#Preview {
    HomeView()
}
