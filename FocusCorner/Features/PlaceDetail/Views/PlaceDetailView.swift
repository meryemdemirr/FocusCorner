//
//  PlaceDetailView.swift
//  FocusCorner

import SwiftUI

struct PlaceDetailView: View {

    @State private var viewModel: PlaceDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(place: CommunityPlace) {
        _viewModel = State(initialValue: PlaceDetailViewModel(place: place))
    }

    var body: some View {
        ZStack(alignment: .top) {
            AppColors.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroImage
                    contentSection
                }
                .padding(.bottom, AppSpacing.xxl + AppSpacing.xxl)
            }
            .scrollIndicators(.hidden)

            headerButtons
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Hero image

    private var heroImage: some View {
        Group {
            if let urlString = viewModel.place.imageURLs.first,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        imagePlaceholder
                    }
                }
                .frame(height: 300)
                .clipped()
            } else {
                imagePlaceholder
                    .frame(height: 300)
            }
        }
    }

    private var imagePlaceholder: some View {
        LinearGradient(
            colors: [AppColors.lightCaramel, AppColors.coffeeBrown],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 56, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    // MARK: - Header overlay buttons

    private var headerButtons: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.coffeeBrown)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(.ultraThinMaterial))
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)

            Spacer()

            Button { viewModel.toggleSave() } label: {
                Image(systemName: viewModel.isSaved ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(viewModel.isSaved ? AppColors.caramel : AppColors.coffeeBrown)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(.ultraThinMaterial))
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.lg)
    }

    // MARK: - Content

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            titleBlock
            if !viewModel.place.vibeTags.isEmpty { vibeTagsRow }
            if !viewModel.place.description.isEmpty { descriptionBlock }
            infoCards
            if !viewModel.place.notes.isEmpty { notesBlock }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.lg)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(viewModel.place.name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            if !viewModel.place.locationLabel.isEmpty {
                Label(viewModel.place.locationLabel, systemImage: "mappin.circle.fill")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.caramel.opacity(0.7))
                Text("Added by \(viewModel.place.contributorEmail)")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.65))
            }
        }
    }

    private var vibeTagsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                ForEach(viewModel.place.vibeTags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.coffeeBrown)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xxs + 2)
                        .background(Capsule().fill(AppColors.caramel.opacity(0.12)))
                        .overlay(Capsule().stroke(AppColors.caramel.opacity(0.25), lineWidth: 1))
                }
            }
        }
    }

    private var descriptionBlock: some View {
        Text(viewModel.place.description)
            .font(AppTypography.body)
            .foregroundStyle(AppColors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var infoCards: some View {
        VStack(spacing: AppSpacing.sm) {
            infoRow(icon: "wifi", label: "WiFi", value: viewModel.place.wifiQuality)
            infoRow(icon: "speaker.wave.2.fill", label: "Noise Level", value: viewModel.place.noiseLevel)
            infoRow(icon: "sofa.fill", label: "Comfort", value: viewModel.place.comfortLevel)
            if !viewModel.place.openingHours.isEmpty {
                infoRow(icon: "clock.fill", label: "Hours", value: viewModel.place.openingHours)
            }
        }
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.caramel.opacity(0.10))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColors.caramel)
            }
            Text(label)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(AppSpacing.md)
        .background(cardBackground)
    }

    private var notesBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Label("Notes", systemImage: "note.text")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
            Text(viewModel.place.notes)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.md)
        .background(cardBackground)
    }

    // MARK: - Helpers

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
            .fill(AppColors.beigeSurface.opacity(0.85))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(AppColors.warmSand.opacity(0.5), lineWidth: 1)
            )
    }
}
