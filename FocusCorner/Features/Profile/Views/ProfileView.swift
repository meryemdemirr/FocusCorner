//
//  ProfileView.swift
//  FocusCorner
//

import SwiftUI

struct ProfileView: View {

    @State private var viewModel = ProfileViewModel()
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        FeaturePlaceholderScreen(
            symbol: "person.crop.circle.fill",
            title: L10n.Profile.title,
            subtitle: L10n.Profile.subtitle,
            placeholder: L10n.Profile.placeholder
        ) {
            Button {
                coordinator.signOut()
            } label: {
                Text(L10n.Profile.signOut)
                    .font(AppTypography.button)
                    .foregroundStyle(AppColors.coffeeBrown)
                    .padding(.vertical, AppSpacing.sm)
                    .padding(.horizontal, AppSpacing.lg)
                    .background(
                        Capsule()
                            .fill(AppColors.beigeSurface.opacity(0.85))
                            .overlay(
                                Capsule().stroke(AppColors.warmSand, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, AppSpacing.md)
        }
    }
}

#Preview {
    ProfileView()
        .environment(AppCoordinator())
}
