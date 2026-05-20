//
//  MapView.swift
//  FocusCorner

import SwiftUI
import MapKit

// MARK: - Teardrop pin shape

private struct PlacePinShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height * 0.7) / 2
        let centerX = rect.midX
        let circleBottom = radius * 2
        path.addEllipse(in: CGRect(x: centerX - radius, y: 0, width: radius * 2, height: radius * 2))
        path.move(to: CGPoint(x: centerX - radius * 0.35, y: circleBottom - 4))
        path.addQuadCurve(
            to: CGPoint(x: centerX + radius * 0.35, y: circleBottom - 4),
            control: CGPoint(x: centerX, y: rect.maxY)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - View

struct MapView: View {

    @State private var viewModel = MapViewModel()
    @State private var hasAppeared = false
    @FocusState private var isSearchFocused: Bool

    // Zoom span tracked separately so +/- buttons can adjust it independently.
    @State private var currentSpan = MapViewModel.displaySpan

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: MapViewModel.ankaraCoordinate,
            span: MapViewModel.displaySpan
        )
    )

    // Min / max latitude delta for zoom limits
    private let minSpanDelta: CLLocationDegrees = 0.003   // ~330m — very close
    private let maxSpanDelta: CLLocationDegrees = 0.18    // ~20km — city-level

    var body: some View {
        ZStack(alignment: .top) {
            // Full-screen map layer
            mapLayer
                .ignoresSafeArea()

            // Floating top controls
            VStack(spacing: 0) {
                mapSearchHeader
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.lg)
                Spacer()
            }

            // Right-side floating controls (zoom + location)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    rightSideControls
                        .padding(.trailing, AppSpacing.md)
                        .padding(.bottom, 220)
                }
            }

            // Bottom panel: selected place card or nearby strip
            VStack {
                Spacer()
                bottomPanel
                    .padding(.bottom, AppSpacing.xxl + AppSpacing.xl)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: isSearchFocused) { _, isFocused in
            viewModel.isSearchFocused = isFocused
        }
        .onAppear {
            viewModel.startLocationFlow()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.05)) {
                hasAppeared = true
            }
        }
        // When the VM determines a new center (location acquired / search result), animate camera.
        .onChange(of: viewModel.cameraUpdateID) { _, _ in
            withAnimation(.easeInOut(duration: 0.9)) {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: viewModel.centerCoordinate,
                        span: currentSpan
                    )
                )
            }
        }
    }

    // MARK: - Full-screen map

    private var mapLayer: some View {
        Map(position: $cameraPosition) {
            ForEach(viewModel.places) { place in
                Annotation("", coordinate: place.coordinate, anchor: .bottom) {
                    placePin(place)
                }
            }
            UserAnnotation()
        }
        .mapStyle(.standard(emphasis: .muted, pointsOfInterest: .all))
        .mapControls {
            MapCompass().mapControlVisibility(.automatic)
        }
    }

    // MARK: - Teardrop pin with name label

    private func placePin(_ place: PlaceSearchResult) -> some View {
        let isSelected = viewModel.selectedPlace?.id == place.id
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                viewModel.selectMapPlace(place)
            }
        } label: {
            VStack(spacing: 2) {
                ZStack {
                    PlacePinShape()
                        .fill(isSelected ? AppColors.coffeeBrown : .white)
                        .frame(width: 36, height: 44)
                        .shadow(
                            color: isSelected
                                ? AppColors.coffeeBrown.opacity(0.4)
                                : Color.black.opacity(0.18),
                            radius: isSelected ? 8 : 5,
                            x: 0, y: 3
                        )
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : AppColors.caramel)
                        .offset(y: -5)
                }
                .scaleEffect(isSelected ? 1.15 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)

                Text(place.name)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.horizontal, AppSpacing.xs)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.95))
                            .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 1)
                    )
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Floating search header

    private var mapSearchHeader: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)

                TextField("Kafe, semt, çalışma alanı ara…", text: searchBinding)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.search)
                    .focused($isSearchFocused)
                    .onSubmit {
                        viewModel.submitSearch()
                        isSearchFocused = false
                    }

                if !viewModel.searchText.isEmpty {
                    Button { viewModel.updateSearchText("") } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(AppColors.textSecondary.opacity(0.55))
                    }
                    .buttonStyle(.plain)
                }

                if viewModel.isLoading {
                    ProgressView()
                        .tint(AppColors.coffeeBrown)
                        .scaleEffect(0.75)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(.ultraThickMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                            .stroke(AppColors.warmSand.opacity(0.5), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 6)

            if isSearchFocused && !viewModel.searchSuggestions.isEmpty {
                searchSuggestionsList
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            HStack(spacing: AppSpacing.xs) {
                Image(systemName: viewModel.hasUserLocation ? "location.fill" : "location")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(viewModel.hasUserLocation ? AppColors.caramel : AppColors.textSecondary)
                Text(viewModel.locationStatusMessage)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xxs)
            .background(Capsule().fill(.ultraThinMaterial).opacity(0.9))
        }
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : -10)
        .animation(.spring(response: 0.55, dampingFraction: 0.85), value: hasAppeared)
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: viewModel.searchSuggestions.count)
    }

    private var searchBinding: Binding<String> {
        Binding(
            get: { viewModel.searchText },
            set: { viewModel.updateSearchText($0) }
        )
    }

    private var searchSuggestionsList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.searchSuggestions) { suggestion in
                Button {
                    isSearchFocused = false
                    viewModel.selectSuggestion(suggestion)
                } label: {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppColors.caramel)
                            .frame(width: 26, height: 26)
                            .background(Circle().fill(AppColors.caramel.opacity(0.1)))

                        VStack(alignment: .leading, spacing: 1) {
                            Text(suggestion.title)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppColors.textPrimary)
                                .lineLimit(1)
                            if !suggestion.subtitle.isEmpty {
                                Text(suggestion.subtitle)
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundStyle(AppColors.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                }
                .buttonStyle(.plain)

                if suggestion.id != viewModel.searchSuggestions.last?.id {
                    Divider()
                        .background(AppColors.warmSand.opacity(0.4))
                        .padding(.leading, 50)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .fill(.ultraThickMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .stroke(AppColors.warmSand.opacity(0.45), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 5)
    }

    // MARK: - Right-side floating controls

    private var rightSideControls: some View {
        VStack(spacing: AppSpacing.sm) {
            // Zoom controls grouped together
            VStack(spacing: 0) {
                zoomButton(icon: "plus", action: zoomIn, isDisabled: isAtMaxZoom)

                Divider()
                    .background(AppColors.warmSand.opacity(0.55))
                    .padding(.horizontal, 8)

                zoomButton(icon: "minus", action: zoomOut, isDisabled: isAtMinZoom)
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThickMaterial)
                    .shadow(color: Color.black.opacity(0.14), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppColors.warmSand.opacity(0.4), lineWidth: 1)
            )

            // Location button below zoom controls
            Button {
                isSearchFocused = false
                viewModel.requestLocationAgain()
            } label: {
                Image(systemName: viewModel.hasUserLocation ? "location.fill" : "location")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(viewModel.hasUserLocation ? AppColors.caramel : AppColors.coffeeBrown)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThickMaterial)
                            .shadow(color: Color.black.opacity(0.14), radius: 8, x: 0, y: 4)
                    )
                    .overlay(Circle().stroke(AppColors.warmSand.opacity(0.4), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private func zoomButton(icon: String, action: @escaping () -> Void, isDisabled: Bool) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(isDisabled ? AppColors.textSecondary.opacity(0.3) : AppColors.coffeeBrown)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    // MARK: - Zoom helpers

    private var isAtMaxZoom: Bool { currentSpan.latitudeDelta <= minSpanDelta }
    private var isAtMinZoom: Bool { currentSpan.latitudeDelta >= maxSpanDelta }

    private func zoomIn() {
        let newDelta = max(currentSpan.latitudeDelta / 2.0, minSpanDelta)
        applyZoom(delta: newDelta)
    }

    private func zoomOut() {
        let newDelta = min(currentSpan.latitudeDelta * 2.0, maxSpanDelta)
        applyZoom(delta: newDelta)
    }

    private func applyZoom(delta: CLLocationDegrees) {
        currentSpan = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        let center = currentCenter
        withAnimation(.easeInOut(duration: 0.35)) {
            cameraPosition = .region(MKCoordinateRegion(center: center, span: currentSpan))
        }
    }

    /// Reads the current map center from the camera position binding.
    private var currentCenter: CLLocationCoordinate2D {
        cameraPosition.region?.center ?? viewModel.centerCoordinate
    }

    // MARK: - Bottom panel

    @ViewBuilder
    private var bottomPanel: some View {
        if let selected = viewModel.selectedPlace {
            selectedPlaceCard(selected)
                .padding(.horizontal, AppSpacing.md)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
        } else if !viewModel.places.isEmpty {
            nearbyScrollStrip
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Selected place card

    private func selectedPlaceCard(_ place: PlaceSearchResult) -> some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .fill(AppColors.caramelGradient)
                    .frame(width: 52, height: 52)
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(place.name)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text(place.subtitle.isEmpty ? "MapKit place" : place.subtitle)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
                Text(viewModel.distanceText(for: place))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.coffeeBrown.opacity(0.7))
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    viewModel.selectedPlace = nil
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(AppColors.warmSand.opacity(0.6)))
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(.ultraThickMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.warmSand.opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 8)
    }

    // MARK: - Nearby horizontal strip

    private var nearbyScrollStrip: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Bu Bölgede")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(Array(viewModel.places.prefix(10).enumerated()), id: \.element.id) { index, place in
                        nearbyChip(place)
                            .opacity(hasAppeared ? 1 : 0)
                            .offset(x: hasAppeared ? 0 : 20)
                            .animation(
                                .spring(response: 0.45, dampingFraction: 0.8).delay(Double(index) * 0.04),
                                value: hasAppeared
                            )
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.xs)
            }
        }
        .padding(.vertical, AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(.ultraThickMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.warmSand.opacity(0.4), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.10), radius: 18, x: 0, y: 8)
        .padding(.horizontal, AppSpacing.md)
    }

    private func nearbyChip(_ place: PlaceSearchResult) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                viewModel.selectMapPlace(place)
            }
        } label: {
            HStack(spacing: AppSpacing.xs) {
                ZStack {
                    Circle()
                        .fill(AppColors.caramel.opacity(0.15))
                        .frame(width: 30, height: 30)
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.caramel)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(place.name)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                    Text(place.street ?? "Yakında")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .fill(AppColors.beigeSurface.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                            .stroke(AppColors.warmSand.opacity(0.6), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MapView()
}
