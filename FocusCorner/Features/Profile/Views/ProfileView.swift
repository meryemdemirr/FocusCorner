//
//  ProfileView.swift
//  FocusCorner
//

import SwiftUI

struct ProfileView: View {

    @State private var viewModel = ProfileViewModel()
    @State private var authState = AuthStateViewModel()
    @Environment(AppCoordinator.self) private var coordinator

    @State private var hasAppeared = false
    @State private var showSignOutConfirm = false
    @State private var showDeleteConfirm = false
    @State private var isDeletingAccount = false
    @State private var deleteError: AuthError? = nil

    var body: some View {
        ZStack {
            AppColors.backgroundGradient.ignoresSafeArea()
            backdrop

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    headerRow
                    avatarSection
                    settingsSection
                    accountSection
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
        // Sign-out confirmation
        .confirmationDialog(
            Text(L10n.Profile.signOutConfirmTitle),
            isPresented: $showSignOutConfirm,
            titleVisibility: .visible
        ) {
            Button(L10n.Profile.signOut, role: .destructive) {
                coordinator.signOut()
            }
            Button(L10n.Common.cancel, role: .cancel) {}
        }
        // Delete account confirmation
        .confirmationDialog(
            Text(L10n.Profile.deleteConfirmTitle),
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(L10n.Profile.deleteAccount, role: .destructive) {
                Task { await handleDeleteAccount() }
            }
            Button(L10n.Common.cancel, role: .cancel) {}
        } message: {
            Text(L10n.Profile.deleteConfirmMessage)
        }
        // Delete error alert
        .alert(
            deleteError?.alertTitle ?? "",
            isPresented: Binding(
                get: { deleteError != nil },
                set: { if !$0 { deleteError = nil } }
            )
        ) {
            Button("OK", role: .cancel) { deleteError = nil }
        } message: {
            if let error = deleteError {
                Text(error.errorDescription ?? "")
            }
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(L10n.Profile.title)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
            Text(L10n.Profile.subtitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
        }
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 12)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.05), value: hasAppeared)
    }

    // MARK: - Avatar section

    private var avatarSection: some View {
        HStack(spacing: AppSpacing.lg) {
            avatarCircle
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(authState.currentUserEmail ?? "—")
                    .font(AppTypography.button)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text(L10n.Profile.memberLabel)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
        }
        .padding(AppSpacing.md)
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
        .offset(y: hasAppeared ? 0 : 14)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.1), value: hasAppeared)
    }

    private var avatarCircle: some View {
        ZStack {
            Circle()
                .fill(AppColors.caramelGradient)
                .frame(width: 56, height: 56)
            Text(initials)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textOnAccent)
        }
    }

    private var initials: String {
        guard let email = authState.currentUserEmail,
              let first = email.first else { return "?" }
        return String(first).uppercased()
    }

    // MARK: - Settings section

    private var settingsSection: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "bell.fill", iconColor: .orange.opacity(0.8),
                        label: "Notifications")
            rowDivider
            settingsRow(icon: "moon.fill", iconColor: .indigo.opacity(0.7),
                        label: "Appearance")
            rowDivider
            settingsRow(icon: "questionmark.circle.fill", iconColor: .blue.opacity(0.6),
                        label: "Help & Support")
            rowDivider
            settingsRow(icon: "info.circle.fill", iconColor: AppColors.coffeeBrown,
                        label: "About FocusCorner")
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
        .offset(y: hasAppeared ? 0 : 18)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.16), value: hasAppeared)
    }

    private var rowDivider: some View {
        Divider()
            .background(AppColors.warmSand.opacity(0.5))
            .padding(.leading, 56)
    }

    private func settingsRow(icon: String, iconColor: Color, label: String) -> some View {
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
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary.opacity(0.4))
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm + 2)
        .contentShape(Rectangle())
    }

    // MARK: - Account section

    private var accountSection: some View {
        VStack(spacing: AppSpacing.sm) {
            signOutButton
            deleteAccountButton
        }
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 22)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.22), value: hasAppeared)
    }

    private var signOutButton: some View {
        Button {
            showSignOutConfirm = true
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15, weight: .medium))
                Text(L10n.Profile.signOut)
                    .font(AppTypography.button)
                Spacer()
            }
            .foregroundStyle(AppColors.coffeeBrown)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(AppColors.beigeSurface.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                            .stroke(AppColors.warmSand.opacity(0.5), lineWidth: 1)
                    )
            )
            .shadow(color: AppColors.coffeeBrown.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var deleteAccountButton: some View {
        Button {
            showDeleteConfirm = true
        } label: {
            HStack(spacing: AppSpacing.sm) {
                if isDeletingAccount {
                    ProgressView()
                        .tint(Color.red.opacity(0.7))
                        .frame(width: 15, height: 15)
                } else {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .medium))
                }
                Text(isDeletingAccount ? L10n.Profile.deletingAccount : L10n.Profile.deleteAccount)
                    .font(AppTypography.button)
                Spacer()
            }
            .foregroundStyle(Color.red.opacity(0.75))
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(Color.red.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                            .stroke(Color.red.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isDeletingAccount)
    }

    // MARK: - Backdrop

    private var backdrop: some View {
        ZStack {
            Circle()
                .fill(AppColors.lightCaramel.opacity(0.3))
                .frame(width: 240, height: 240)
                .blur(radius: 80)
                .offset(x: 140, y: -180)
            Circle()
                .fill(AppColors.warmSand.opacity(0.4))
                .frame(width: 280, height: 280)
                .blur(radius: 90)
                .offset(x: -120, y: 340)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    // MARK: - Actions

    private func handleDeleteAccount() async {
        isDeletingAccount = true
        do {
            try await AuthService.shared.deleteAccount()
            // Firebase listener fires → coordinator transitions to .authentication
        } catch {
            deleteError = AuthService.shared.mapError(error)
        }
        isDeletingAccount = false
    }
}

#Preview {
    ProfileView()
        .environment(AppCoordinator())
}
