//
//  HomeView.swift
//  FocusCorner

import SwiftUI

private struct FilterChip: Identifiable, Hashable {
    let id: String
    let label: String
    let icon: String

    static let all: [FilterChip] = [
        FilterChip(id: "coffee",  label: "Coffee",  icon: "cup.and.saucer"),
        FilterChip(id: "study",   label: "Study",   icon: "books.vertical"),
        FilterChip(id: "quiet",   label: "Quiet",   icon: "moon"),
        FilterChip(id: "cozy",    label: "Cozy",    icon: "house"),
        FilterChip(id: "outdoor", label: "Outdoor", icon: "leaf"),
        FilterChip(id: "library", label: "Library", icon: "building.columns")
    ]
}

// MARK: - View

struct HomeView: View {

    @State private var viewModel = HomeViewModel()
    @State private var selectedChip: FilterChip? = nil
    @State private var hasAppeared = false
    @State private var selectedPlace: CommunityPlace? = nil
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack(alignment: .top) {
            AppColors.backgroundGradient.ignoresSafeArea()
            backdrop

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerRow
                    if viewModel.isSearchExpanded {
                        floatingSearchPanel
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.bottom, AppSpacing.lg)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    filterBar
                    featuredSection
                    nearbySection
                }
                .padding(.bottom, AppSpacing.xxl + AppSpacing.xxl)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.isSearchExpanded)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.05)) {
                hasAppeared = true
            }
        }
        .sheet(item: $selectedPlace) { place in
            PlaceDetailView(place: place)
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good morning")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                Text("Find your focus corner today")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Button {
                viewModel.toggleSearch()
                isSearchFocused = viewModel.isSearchExpanded
            } label: {
                Image(systemName: viewModel.isSearchExpanded ? "xmark" : "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.coffeeBrown)
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(AppColors.beigeSurface.opacity(0.9))
                            .overlay(Circle().stroke(AppColors.warmSand.opacity(0.7), lineWidth: 1))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.lg)
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : -8)
        .animation(.spring(response: 0.55, dampingFraction: 0.85), value: hasAppeared)
    }

    private var floatingSearchPanel: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)

                TextField("Search cafes, cities, workspaces", text: searchBinding)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .textInputAutocapitalization(.words)
                    .submitLabel(.search)
                    .focused($isSearchFocused)
                    .onSubmit {
                        viewModel.submitSearch()
                        isSearchFocused = false
                    }

                if viewModel.isSearching {
                    ProgressView()
                        .tint(AppColors.coffeeBrown)
                        .scaleEffect(0.75)
                }
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                            .stroke(AppColors.warmSand.opacity(0.65), lineWidth: 1)
                    )
            )

            if !viewModel.suggestions.isEmpty && isSearchFocused {
                VStack(spacing: 0) {
                    ForEach(viewModel.suggestions) { suggestion in
                        Button {
                            isSearchFocused = false
                            viewModel.selectSuggestion(suggestion)
                        } label: {
                            suggestionRow(title: suggestion.title, subtitle: suggestion.subtitle)
                        }
                        .buttonStyle(.plain)

                        if suggestion.id != viewModel.suggestions.last?.id {
                            Divider().background(AppColors.warmSand.opacity(0.45)).padding(.leading, 56)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .fill(AppColors.beigeSurface.opacity(0.96))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                .stroke(AppColors.warmSand.opacity(0.55), lineWidth: 1)
                        )
                )
            }
        }
        .shadow(color: AppColors.coffeeBrown.opacity(0.10), radius: 14, x: 0, y: 6)
    }

    private var searchBinding: Binding<String> {
        Binding(
            get: { viewModel.searchText },
            set: { viewModel.updateSearchText($0) }
        )
    }

    private func suggestionRow(title: String, subtitle: String) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.caramel)
                .frame(width: 30, height: 30)
                .background(Circle().fill(AppColors.caramel.opacity(0.12)))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
    }

    // MARK: - Filter chips

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                ForEach(FilterChip.all) { chip in
                    chipButton(chip)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .padding(.bottom, AppSpacing.xl)
        .opacity(hasAppeared ? 1 : 0)
        .animation(.spring(response: 0.55, dampingFraction: 0.85).delay(0.06), value: hasAppeared)
    }

    private func chipButton(_ chip: FilterChip) -> some View {
        let isSelected = selectedChip == chip
        return Button {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
                selectedChip = isSelected ? nil : chip
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: chip.icon)
                    .font(.system(size: 11, weight: .medium))
                Text(chip.label)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(isSelected ? AppColors.textOnAccent : AppColors.textSecondary)
            .padding(.vertical, 7)
            .padding(.horizontal, AppSpacing.sm)
            .background {
                if isSelected {
                    Capsule().fill(AppColors.caramelGradient)
                } else {
                    Capsule()
                        .fill(AppColors.beigeSurface.opacity(0.9))
                        .overlay(Capsule().stroke(AppColors.warmSand.opacity(0.7), lineWidth: 1))
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Featured section

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionRow(title: "Featured Spots")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    if viewModel.isLoading && viewModel.communityPlaces.isEmpty {
                        loadingCard
                    } else if viewModel.communityPlaces.isEmpty {
                        emptyFeaturedCard
                    } else {
                        ForEach(Array(viewModel.communityPlaces.prefix(8).enumerated()), id: \.element.id) { index, place in
                            featuredCard(place, index: index)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .padding(.bottom, AppSpacing.xl)
        .opacity(hasAppeared ? 1 : 0)
        .animation(.spring(response: 0.55, dampingFraction: 0.85).delay(0.1), value: hasAppeared)
    }

    // MARK: - Nearby section

    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionRow(title: "Community Places")
            VStack(spacing: AppSpacing.sm) {
                if viewModel.isLoading && viewModel.communityPlaces.isEmpty {
                    ProgressView()
                        .tint(AppColors.coffeeBrown)
                        .padding(.vertical, AppSpacing.xl)
                        .frame(maxWidth: .infinity)
                } else if viewModel.communityPlaces.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.communityPlaces) { place in
                        Button {
                            selectedPlace = place
                        } label: {
                            nearbyRow(place)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .opacity(hasAppeared ? 1 : 0)
        .animation(.spring(response: 0.55, dampingFraction: 0.85).delay(0.15), value: hasAppeared)
    }

    // MARK: - Cards

    private func featuredCard(_ place: CommunityPlace, index: Int) -> some View {
        Button {
            selectedPlace = place
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    if let urlString = place.imageURLs.first, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            if case .success(let img) = phase {
                                img.resizable().scaledToFill()
                            } else {
                                cardGradient(index: index)
                            }
                        }
                    } else {
                        cardGradient(index: index)
                    }
                }
                .frame(width: 220, height: 148)
                .clipped()
                .overlay(alignment: .bottomLeading) {
                    if !place.displayCity.isEmpty {
                        Label(place.displayCity, systemImage: "mappin.fill")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.black.opacity(0.22)))
                            .padding(AppSpacing.sm)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(place.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                    Text(place.vibeTags.first ?? "Community place")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.sm)
                .background(Color.white.opacity(0.65))
            }
            .frame(width: 220)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: AppColors.coffeeBrown.opacity(0.10), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private func cardGradient(index: Int) -> some View {
        LinearGradient(
            colors: [
                index.isMultiple(of: 2) ? AppColors.lightCaramel : AppColors.warmSand,
                index.isMultiple(of: 3) ? AppColors.coffeeBrown : AppColors.caramel
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func nearbyRow(_ place: CommunityPlace) -> some View {
        HStack(spacing: AppSpacing.md) {
            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                .fill(AppColors.caramelGradient)
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(place.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text(place.locationLabel.isEmpty ? (place.vibeTags.first ?? "Community place") : place.locationLabel)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary.opacity(0.4))
        }
        .padding(AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .fill(AppColors.beigeSurface.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .stroke(AppColors.warmSand.opacity(0.55), lineWidth: 1)
                )
        )
        .shadow(color: AppColors.coffeeBrown.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    // MARK: - Empty / Loading states

    private var loadingCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ProgressView().tint(AppColors.coffeeBrown)
            Text("Loading community places")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            Text("Places added by the community appear here.")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
        }
        .frame(width: 220, height: 176, alignment: .leading)
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.beigeSurface.opacity(0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.warmSand.opacity(0.55), lineWidth: 1)
                )
        )
    }

    private var emptyFeaturedCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Image(systemName: "plus.circle")
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(AppColors.caramel.opacity(0.6))
            Text("Be the first!")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            Text("Add a cafe or workspace using the + tab.")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
        }
        .frame(width: 220, height: 176, alignment: .leading)
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.beigeSurface.opacity(0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.warmSand.opacity(0.55), lineWidth: 1)
                )
        )
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "plus.circle")
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(AppColors.textSecondary.opacity(0.42))
            Text("No community places yet. Be the first to add a cafe or workspace!")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary.opacity(0.65))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.warmSand.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.warmSand.opacity(0.35), lineWidth: 1)
                )
        )
    }

    // MARK: - Helpers

    private func sectionRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    private var backdrop: some View {
        ZStack {
            Circle()
                .fill(AppColors.lightCaramel.opacity(0.22))
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(x: 130, y: -80)
            Circle()
                .fill(AppColors.warmSand.opacity(0.35))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: -120, y: 360)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

#Preview {
    HomeView()
}
