//
//  MapView.swift
//  FocusCorner
//

import SwiftUI
import MapKit

struct MapView: View {

    @State private var viewModel = MapViewModel()
    @State private var hasAppeared = false

    // Camera state lives here (not in the ViewModel) to avoid
    // MapKit types causing issues with the @Observable macro expansion.
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: MapViewModel.ankaraCoordinate,
            span: MapViewModel.displaySpan
        )
    )

    var body: some View {
        ZStack(alignment: .top) {
            AppColors.backgroundGradient.ignoresSafeArea()
            backdrop

            VStack(spacing: 0) {
                headerRow
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.md)
                    .padding(.bottom, AppSpacing.md)

                mapSection
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xl)

                nearbySection
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.startLocationFlow()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.05)) {
                hasAppeared = true
            }
        }
        // When ViewModel determines a new center, animate the camera there.
        .onChange(of: viewModel.cameraUpdateID) { _, _ in
            withAnimation(.easeInOut(duration: 0.9)) {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: viewModel.centerCoordinate,
                        span: MapViewModel.displaySpan
                    )
                )
            }
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.Map.title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                Group {
                    if viewModel.isLoading {
                        Text("Searching nearby cafes…")
                    } else if viewModel.places.isEmpty {
                        Text("Discovering spots near you")
                    } else {
                        Text("\(viewModel.places.count) cozy spots found")
                    }
                }
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .animation(.easeInOut(duration: 0.3), value: viewModel.places.count)
            }
            Spacer()
            Button {
                viewModel.requestLocationAgain()
            } label: {
                Image(systemName: viewModel.hasUserLocation ? "location.fill" : "location")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(viewModel.hasUserLocation
                                     ? AppColors.caramel
                                     : AppColors.coffeeBrown)
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(AppColors.beigeSurface.opacity(0.9))
                            .overlay(Circle().stroke(AppColors.warmSand.opacity(0.7), lineWidth: 1))
                    )
            }
            .buttonStyle(.plain)
        }
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : -8)
        .animation(.spring(response: 0.55, dampingFraction: 0.85), value: hasAppeared)
    }

    // MARK: - Map

    private var mapSection: some View {
        Map(position: $cameraPosition) {
            ForEach(viewModel.places) { place in
                Marker(place.name, systemImage: "cup.and.saucer.fill",
                       coordinate: place.coordinate)
                    .tint(AppColors.caramel)
            }
            UserAnnotation()
        }
        .mapStyle(.standard(emphasis: .muted, pointsOfInterest: .excludingAll))
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                .stroke(AppColors.warmSand.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: AppColors.coffeeBrown.opacity(0.08), radius: 16, x: 0, y: 6)
        .overlay(alignment: .bottomTrailing) {
            if viewModel.isLoading {
                loadingBadge
                    .padding(AppSpacing.sm)
                    .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .bottomTrailing)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
        .opacity(hasAppeared ? 1 : 0)
        .scaleEffect(hasAppeared ? 1 : 0.97)
        .animation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.08), value: hasAppeared)
    }

    private var loadingBadge: some View {
        HStack(spacing: AppSpacing.xs) {
            ProgressView()
                .tint(AppColors.coffeeBrown)
                .scaleEffect(0.75)
            Text("Searching…")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(AppColors.coffeeBrown.opacity(0.8))
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().stroke(AppColors.warmSand.opacity(0.5), lineWidth: 1))
        )
    }

    // MARK: - Nearby list

    private var nearbySection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("In This Area")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, AppSpacing.lg)

                if viewModel.places.isEmpty && !viewModel.isLoading {
                    emptyNearbyState
                        .padding(.horizontal, AppSpacing.lg)
                } else {
                    VStack(spacing: AppSpacing.sm) {
                        ForEach(Array(viewModel.places.prefix(6).enumerated()), id: \.element.id) { index, place in
                            nearbyRow(place, index: index)
                                .opacity(hasAppeared ? 1 : 0)
                                .offset(y: hasAppeared ? 0 : 10)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.8).delay(0.15 + Double(index) * 0.05),
                                    value: hasAppeared
                                )
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
            }
            .padding(.bottom, AppSpacing.xxl + AppSpacing.xxl)
        }
        .scrollIndicators(.hidden)
    }

    private func nearbyRow(_ place: CafePlace, index: Int) -> some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.caramel.opacity(0.12 + Double(index % 3) * 0.06))
                    .frame(width: 44, height: 44)
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(AppColors.caramel)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(place.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text(place.street ?? "Nearby")
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

    private var emptyNearbyState: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "map")
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(AppColors.textSecondary.opacity(0.35))
            Text("Spots will appear once your location is confirmed.")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary.opacity(0.55))
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

    // MARK: - Backdrop

    private var backdrop: some View {
        ZStack {
            Circle()
                .fill(AppColors.lightCaramel.opacity(0.25))
                .frame(width: 260, height: 260)
                .blur(radius: 85)
                .offset(x: 140, y: -220)
            Circle()
                .fill(AppColors.warmSand.opacity(0.35))
                .frame(width: 300, height: 300)
                .blur(radius: 95)
                .offset(x: -130, y: 360)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

#Preview {
    MapView()
}
