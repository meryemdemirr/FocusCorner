//
//  AddPlaceView.swift
//  FocusCorner
//

import SwiftUI

struct AddPlaceView: View {

    @State private var viewModel = AddPlaceViewModel()

    var body: some View {
        FeaturePlaceholderScreen(
            symbol: "plus.viewfinder",
            title: L10n.AddPlace.title,
            subtitle: L10n.AddPlace.subtitle,
            placeholder: L10n.AddPlace.placeholder
        )
    }
}

#Preview {
    AddPlaceView()
}
