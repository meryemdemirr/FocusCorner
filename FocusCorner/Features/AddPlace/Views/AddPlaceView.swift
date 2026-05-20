//
//  AddPlaceView.swift
//  FocusCorner
//

import SwiftUI

struct AddPlaceView: View {

    @State private var viewModel = AddPlaceViewModel()
    @State private var hasAppeared = false

    var body: some View {
        ZStack {
            AppColors.backgroundGradient.ignoresSafeArea()
            backdrop

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    headerRow
                    photoPlaceholder
                    formSection
                    submitButton
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xxl)
            }
            .scrollDismissesKeyboard(.interactively)
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

    // MARK: - Photo placeholder

    private var photoPlaceholder: some View {
        ZStack {
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
                Text("Tap to upload up to 5 photos")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 16)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.12), value: hasAppeared)
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 0) {
            formRow(icon: "mappin.circle.fill", iconColor: AppColors.caramel,
                    label: "Place Name", value: "Enter the name")
            rowDivider
            formRow(icon: "location.fill", iconColor: .orange.opacity(0.8),
                    label: "Address", value: "Street, City")
            rowDivider
            formRow(icon: "tag.fill", iconColor: AppColors.coffeeBrown,
                    label: "Category", value: "Coffee Shop")
            rowDivider
            formRow(icon: "wifi", iconColor: .blue.opacity(0.7),
                    label: "WiFi Quality", value: "Select rating")
            rowDivider
            formRow(icon: "speaker.wave.2.fill", iconColor: .purple.opacity(0.6),
                    label: "Noise Level", value: "Select level")
            rowDivider
            formRow(icon: "clock.fill", iconColor: .green.opacity(0.7),
                    label: "Opening Hours", value: "Add hours")
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
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 20)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.18), value: hasAppeared)
    }

    private var rowDivider: some View {
        Divider()
            .background(AppColors.warmSand.opacity(0.5))
            .padding(.leading, 56)
    }

    private func formRow(icon: String, iconColor: Color, label: String, value: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(iconColor)
            }
            Text(label)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text(value)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary.opacity(0.4))
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm + 2)
        .contentShape(Rectangle())
    }

    // MARK: - Submit

    private var submitButton: some View {
        PrimaryButton(
            title: "Submit Place",
            systemImage: "paperplane.fill",
            action: {}
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
}

#Preview {
    AddPlaceView()
}
