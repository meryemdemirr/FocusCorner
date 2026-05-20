//
//  AddPlaceView.swift
//  FocusCorner
//

import SwiftUI
import PhotosUI
import UIKit

struct AddPlaceView: View {

    @State private var viewModel = AddPlaceViewModel()
    @State private var hasAppeared = false
    @State private var showPhotoOptions = false
    @State private var showCamera = false
    @State private var showGallery = false
    @FocusState private var focusedField: AddPlaceField?

    private enum AddPlaceField: Hashable {
        case search, name, description, tags, hours, notes
    }

    var body: some View {
        ZStack {
            AppColors.backgroundGradient.ignoresSafeArea()
            backdrop

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    headerRow
                    photoSection
                    formSection
                    submitButton
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xxl)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)

            if viewModel.showSuccessFeedback {
                successToast
                    .transition(.opacity.combined(with: .scale(scale: 0.94)).combined(with: .move(edge: .top)))
                    .zIndex(2)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Add Photos", isPresented: $showPhotoOptions, titleVisibility: .visible) {
            Button("Take Photo") {
                showCamera = true
            }
            Button("Choose From Gallery") {
                showGallery = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Add photos that show the real workspace atmosphere.")
        }
        .photosPicker(
            isPresented: $showGallery,
            selection: photoItemsBinding,
            maxSelectionCount: 5,
            matching: .images
        )
        .sheet(isPresented: $showCamera) {
            CameraPicker { image in
                viewModel.addCameraImage(image)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                hasAppeared = true
            }
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(L10n.AddPlace.title)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
            Text(L10n.AddPlace.subtitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
        }
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 12)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.05), value: hasAppeared)
    }

    // MARK: - Photos

    private var photoSection: some View {
        Button {
            showPhotoOptions = true
        } label: {
            ZStack {
                photoBackground

                if viewModel.selectedImages.isEmpty {
                    VStack(spacing: AppSpacing.sm) {
                        ZStack {
                            Circle()
                                .fill(AppColors.caramelGradient)
                                .frame(width: 48, height: 48)
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(AppColors.textOnAccent)
                        }
                        Text("Add Photos")
                            .font(AppTypography.button)
                            .foregroundStyle(AppColors.coffeeBrown)
                        Text("Take a photo or choose up to 5 images")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.sm) {
                            ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { _, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 126, height: 130)
                                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                            }

                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(AppColors.coffeeBrown)
                                .frame(width: 84, height: 130)
                                .background(
                                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                        .fill(AppColors.beigeSurface.opacity(0.8))
                                )
                        }
                        .padding(AppSpacing.sm)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 16)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.12), value: hasAppeared)
    }

    private var photoBackground: some View {
        RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
            .fill(AppColors.warmSand.opacity(0.45))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.caramel.opacity(0.5), AppColors.warmSand.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
            )
            .frame(height: 160)
    }

    private var photoItemsBinding: Binding<[PhotosPickerItem]> {
        Binding(
            get: { viewModel.selectedPhotoItems },
            set: {
                viewModel.selectedPhotoItems = $0
                viewModel.loadSelectedPhotos()
            }
        )
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: AppSpacing.md) {
            placeSearchSection
            editableFieldsSection
        }
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 20)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.18), value: hasAppeared)
    }

    private var placeSearchSection: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColors.textSecondary)
                TextField("Search and attach a real place", text: placeSearchBinding)
                    .font(AppTypography.body)
                    .textInputAutocapitalization(.words)
                    .focused($focusedField, equals: .search)
            }
            .padding(AppSpacing.md)
            .background(fieldBackground)

            if focusedField == .search && !viewModel.suggestions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(viewModel.suggestions) { suggestion in
                        Button {
                            focusedField = nil
                            viewModel.selectSuggestion(suggestion)
                        } label: {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundStyle(AppColors.caramel)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.title)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundStyle(AppColors.textPrimary)
                                    if !suggestion.subtitle.isEmpty {
                                        Text(suggestion.subtitle)
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                }
                                Spacer()
                            }
                            .padding(AppSpacing.md)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(fieldBackground)
            }
        }
    }

    private var editableFieldsSection: some View {
        VStack(spacing: AppSpacing.sm) {
            editableTextField("Place Name", text: $viewModel.placeName, icon: "mappin.circle.fill", field: .name)
            editableTextField("Description", text: $viewModel.description, icon: "text.alignleft", field: .description, axis: .vertical)
            editableTextField("Vibe Tags", text: $viewModel.vibeTags, icon: "tag.fill", field: .tags)
            optionRow(title: "WiFi Quality", icon: "wifi", value: $viewModel.wifiQuality, options: ["Great", "Good", "Basic", "Unstable"])
            optionRow(title: "Noise Level", icon: "speaker.wave.2.fill", value: $viewModel.noiseLevel, options: ["Quiet", "Moderate", "Lively"])
            optionRow(title: "Comfort", icon: "sofa.fill", value: $viewModel.comfortLevel, options: ["Cozy", "Focused", "Social"])
            editableTextField("Opening Hours", text: $viewModel.openingHours, icon: "clock.fill", field: .hours)
            editableTextField("Notes", text: $viewModel.notes, icon: "note.text", field: .notes, axis: .vertical)
        }
    }

    private var placeSearchBinding: Binding<String> {
        Binding(
            get: { viewModel.searchText },
            set: { viewModel.updateSearchText($0) }
        )
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
            .fill(AppColors.beigeSurface.opacity(0.86))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(AppColors.warmSand.opacity(0.55), lineWidth: 1)
            )
    }

    private func editableTextField(
        _ title: String,
        text: Binding<String>,
        icon: String,
        field: AddPlaceField,
        axis: Axis = .horizontal
    ) -> some View {
        HStack(alignment: axis == .vertical ? .top : .center, spacing: AppSpacing.md) {
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.caramel.opacity(0.12))
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.caramel)
                }
            TextField(title, text: text, axis: axis)
                .font(AppTypography.body)
                .focused($focusedField, equals: field)
                .lineLimit(axis == .vertical ? 3...5 : 1...1)
        }
        .padding(AppSpacing.md)
        .background(fieldBackground)
    }

    private func optionRow(title: String, icon: String, value: Binding<String>, options: [String]) -> some View {
        HStack(spacing: AppSpacing.md) {
            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                .fill(AppColors.caramel.opacity(0.12))
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.caramel)
                }
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Picker(title, selection: value) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu)
            .tint(AppColors.coffeeBrown)
        }
        .padding(AppSpacing.md)
        .background(fieldBackground)
    }

    // MARK: - Submit

    private var submitButton: some View {
        PrimaryButton(
            title: "Submit Place",
            systemImage: "paperplane.fill",
            action: {
                focusedField = nil
                withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                    viewModel.submitContribution()
                }
            }
        )
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 24)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.25), value: hasAppeared)
    }

    // MARK: - Backdrop

    private var backdrop: some View {
        ZStack {
            Circle()
                .fill(AppColors.lightCaramel.opacity(0.3))
                .frame(width: 240, height: 240)
                .blur(radius: 80)
                .offset(x: 140, y: -200)
            Circle()
                .fill(AppColors.warmSand.opacity(0.4))
                .frame(width: 280, height: 280)
                .blur(radius: 90)
                .offset(x: -120, y: 320)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private var successToast: some View {
        VStack {
            HStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(AppColors.caramelGradient)
                        .frame(width: 38, height: 38)
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Contribution Submitted")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(viewModel.selectedPlace == nil ? "Your place details were saved." : "\(viewModel.selectedPlace?.name ?? "Place") was updated.")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
                Spacer()
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
            .shadow(color: AppColors.coffeeBrown.opacity(0.14), radius: 18, x: 0, y: 8)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)
            Spacer()
        }
    }
}

private struct CameraPicker: UIViewControllerRepresentable {
    let onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onImagePicked: (UIImage) -> Void
        let dismiss: DismissAction

        init(onImagePicked: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onImagePicked = onImagePicked
            self.dismiss = dismiss
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}

#Preview {
    AddPlaceView()
}
