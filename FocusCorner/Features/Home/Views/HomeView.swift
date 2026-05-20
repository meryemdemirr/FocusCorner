//
//  HomeView.swift
//  FocusCorner
//

import SwiftUI

// MARK: - Local data models

private struct PlacePreview: Identifiable {
    let id = UUID()
    let name: String
    let tags: String
    let distance: String
    let rating: String
    let colorTop: Color
    let colorBottom: Color

    static let featured: [PlacePreview] = [
        PlacePreview(name: "The Study Room",   tags: "Coffee · Quiet",  distance: "0.3 km", rating: "4.8",
                     colorTop: Color(red: 0.87, green: 0.75, blue: 0.62), colorBottom: Color(red: 0.64, green: 0.44, blue: 0.31)),
        PlacePreview(name: "Brew & Work",      tags: "WiFi · Cozy",     distance: "0.7 km", rating: "4.6",
                     colorTop: Color(red: 0.80, green: 0.68, blue: 0.56), colorBottom: Color(red: 0.55, green: 0.39, blue: 0.27)),
        PlacePreview(name: "Petal & Press",    tags: "Library · Calm",  distance: "1.2 km", rating: "4.9",
                     colorTop: Color(red: 0.78, green: 0.62, blue: 0.48), colorBottom: Color(red: 0.50, green: 0.34, blue: 0.22))
    ]

    static let nearby: [PlacePreview] = [
        PlacePreview(name: "Quiet Hours Café",   tags: "Study · Silent",  distance: "1.1 km", rating: "4.9",
                     colorTop: AppColors.lightCaramel, colorBottom: AppColors.caramel),
        PlacePreview(name: "Paper & Pencil",     tags: "Library · Silent",distance: "1.4 km", rating: "4.7",
                     colorTop: AppColors.warmSand,     colorBottom: AppColors.lightCaramel),
        PlacePreview(name: "Corner Coffee Co.",  tags: "Coffee · Cozy",   distance: "1.8 km", rating: "4.5",
                     colorTop: AppColors.lightCaramel, colorBottom: Color(red: 0.60, green: 0.40, blue: 0.25))
    ]
}

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
    @State private var hasAppeared: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            AppColors.backgroundGradient.ignoresSafeArea()
            backdrop

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerRow
                    filterBar
                    featuredSection
                    nearbySection
                }
                .padding(.bottom, AppSpacing.xxl + AppSpacing.xxl)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.05)) {
                hasAppeared = true
            }
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
            Button {} label: {
                Image(systemName: "magnifyingglass")
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
                    ForEach(PlacePreview.featured) { place in
                        featuredCard(place)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .padding(.bottom, AppSpacing.xl)
        .opacity(hasAppeared ? 1 : 0)
        .animation(.spring(response: 0.55, dampingFraction: 0.85).delay(0.1), value: hasAppeared)
    }

    private func featuredCard(_ place: PlacePreview) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            LinearGradient(
                colors: [place.colorTop, place.colorBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: 200, height: 148)
            .overlay(alignment: .bottomLeading) {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill").font(.system(size: 10))
                    Text(place.rating).font(.system(size: 11, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.black.opacity(0.22)))
                .padding(AppSpacing.sm)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(place.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                HStack {
                    Text(place.tags)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                    Text(place.distance)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.sm)
            .background(Color.white.opacity(0.65))
        }
        .frame(width: 200)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: AppColors.coffeeBrown.opacity(0.10), radius: 12, x: 0, y: 4)
    }

    // MARK: - Nearby section

    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionRow(title: "Near You")
            VStack(spacing: AppSpacing.sm) {
                ForEach(PlacePreview.nearby) { place in
                    nearbyRow(place)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .opacity(hasAppeared ? 1 : 0)
        .animation(.spring(response: 0.55, dampingFraction: 0.85).delay(0.15), value: hasAppeared)
    }

    private func nearbyRow(_ place: PlacePreview) -> some View {
        HStack(spacing: AppSpacing.md) {
            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                .fill(LinearGradient(colors: [place.colorTop, place.colorBottom],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 2) {
                Text(place.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text(place.tags)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10)).foregroundStyle(AppColors.caramel)
                    Text(place.rating)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                    Text("·").foregroundStyle(AppColors.textSecondary.opacity(0.4))
                    Text(place.distance)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                }
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

    // MARK: - Helpers

    private func sectionRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Button {} label: {
                Text("See all")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.coffeeBrown.opacity(0.7))
            }
            .buttonStyle(.plain)
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
