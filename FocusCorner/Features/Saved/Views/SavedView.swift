//
//  SavedView.swift
//  FocusCorner

import SwiftUI

struct SavedView: View {

    @State private var viewModel = SavedViewModel()
    @State private var hasAppeared = false
    @State private var selectedPlace: CommunityPlace? = nil

    var body: some View {
        ZStack {
            AppColors.backgroundGradient.ignoresSafeArea()
            backdrop

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    headerRow
                    savedList
                    if viewModel.savedPlaces.isEmpty && !viewModel.isLoading {
                        emptyStateHint
                    }
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
        .sheet(item: $selectedPlace) { place in
            PlaceDetailView(place: place)
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
            Text("\(viewModel.savedPlaces.count) places")
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
            if viewModel.isLoading && viewModel.savedPlaces.isEmpty {
                ProgressView()
                    .tint(AppColors.coffeeBrown)
                    .padding(AppSpacing.xl)
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(Array(viewModel.savedPlaces.enumerated()), id: \.element.id) { index, place in
                    Button {
                        selectedPlace = place
                    } label: {
                        savedRow(place, index: index)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.removeSaved(place)
                        } label: {
                            Label("Remove", systemImage: "bookmark.slash")
                        }
                    }

                    if index < viewModel.savedPlaces.count - 1 {
                        Divider()
                            .background(AppColors.warmSand.opacity(0.5))
                            .padding(.leading, 72)
                    }
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

    private func savedRow(_ place: CommunityPlace, index: Int) -> some View {
        HStack(spacing: AppSpacing.md) {
            Group {
                if let urlString = place.imageURLs.first, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        if case .success(let img) = phase {
                            img.resizable().scaledToFill()
                        } else {
                            rowGradient(index: index)
                        }
                    }
                } else {
                    rowGradient(index: index)
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
            .overlay {
                if place.imageURLs.isEmpty {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(place.name)
                    .font(AppTypography.button)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text(place.locationLabel.isEmpty ? (place.vibeTags.first ?? "Community place") : place.locationLabel)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                viewModel.removeSaved(place)
            } label: {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColors.caramel)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.md)
    }

    private func rowGradient(index: Int) -> some View {
        LinearGradient(
            colors: [
                index.isMultiple(of: 2) ? AppColors.caramel : AppColors.lightCaramel,
                index.isMultiple(of: 3) ? AppColors.coffeeBrown : AppColors.caramel
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Empty state

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
