//
//  SavedView.swift
//  FocusCorner
//

import SwiftUI

struct SavedView: View {

    @State private var viewModel = SavedViewModel()
    @State private var hasAppeared = false

    private struct SavedSpot: Identifiable {
        let id = UUID()
        let name: String
        let tag: String
        let rating: String
        let gradient: LinearGradient
    }

    private let spots: [SavedSpot] = [
        SavedSpot(
            name: "Arabica Co.",
            tag: "Coffee · Quiet",
            rating: "4.9",
            gradient: LinearGradient(
                colors: [AppColors.caramel, AppColors.coffeeBrown],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        ),
        SavedSpot(
            name: "The Study Room",
            tag: "Library · Study",
            rating: "4.7",
            gradient: LinearGradient(
                colors: [AppColors.warmSand, AppColors.caramel.opacity(0.7)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        ),
        SavedSpot(
            name: "Mellow Pages",
            tag: "Bookstore · Cozy",
            rating: "4.8",
            gradient: LinearGradient(
                colors: [AppColors.lightCaramel, AppColors.caramel],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        ),
    ]

    var body: some View {
        ZStack {
            AppColors.backgroundGradient.ignoresSafeArea()
            backdrop

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    headerRow
                    savedList
                    emptyStateHint
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xxl)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                hasAppeared = true
            }
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(L10n.Saved.title)
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                Text(L10n.Saved.subtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Text("\(spots.count) spots")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xxs)
                .background(Capsule().fill(AppColors.warmSand.opacity(0.55)))
        }
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 12)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.05), value: hasAppeared)
    }

    // MARK: - Saved list

    private var savedList: some View {
        VStack(spacing: 0) {
            ForEach(Array(spots.enumerated()), id: \.element.id) { index, spot in
                savedRow(spot)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 14)
                    .animation(
                        .spring(response: 0.55, dampingFraction: 0.8).delay(Double(index) * 0.08 + 0.12),
                        value: hasAppeared
                    )

                if index < spots.count - 1 {
                    Divider()
                        .background(AppColors.warmSand.opacity(0.5))
                        .padding(.leading, 72)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.beigeSurface.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.warmSand.opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(color: AppColors.coffeeBrown.opacity(0.05), radius: 14, x: 0, y: 6)
    }

    private func savedRow(_ spot: SavedSpot) -> some View {
        HStack(spacing: AppSpacing.md) {
            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                .fill(spot.gradient)
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 3) {
                Text(spot.name)
                    .font(AppTypography.button)
                    .foregroundStyle(AppColors.textPrimary)
                Text(spot.tag)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.caramel)
                    Text(spot.rating)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textPrimary)
                }
                Button {
                    // toggle saved
                } label: {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColors.caramel)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.md)
    }

    // MARK: - Empty state hint

    private var emptyStateHint: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "bookmark")
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(AppColors.textSecondary.opacity(0.35))
            Text(L10n.Saved.placeholder)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary.opacity(0.55))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.warmSand.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.warmSand.opacity(0.35), lineWidth: 1)
                )
        )
        .opacity(hasAppeared ? 1 : 0)
        .animation(.easeIn(duration: 0.4).delay(0.4), value: hasAppeared)
    }

    // MARK: - Backdrop

    private var backdrop: some View {
        ZStack {
            Circle()
                .fill(AppColors.lightCaramel.opacity(0.3))
                .frame(width: 240, height: 240)
                .blur(radius: 80)
                .offset(x: -140, y: -180)
            Circle()
                .fill(AppColors.warmSand.opacity(0.4))
                .frame(width: 280, height: 280)
                .blur(radius: 90)
                .offset(x: 130, y: 320)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

#Preview {
    SavedView()
}
