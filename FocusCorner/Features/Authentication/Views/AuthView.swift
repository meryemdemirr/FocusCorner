//
//  AuthView.swift
//  FocusCorner
//
//  Placeholder authentication screen. Real sign-in fields (email, Apple, Google,
//  etc.) will replace the CTA stack later. For now it just hands the user
//  over to the main app when "Continue" is tapped.
//

import SwiftUI

struct AuthView: View {

    let onAuthenticated: () -> Void

    @State private var viewModel = AuthViewModel()

    var body: some View {
        ZStack {
            AppColors.backgroundGradient.ignoresSafeArea()
            backdrop

            VStack(spacing: AppSpacing.xl) {
                Spacer(minLength: AppSpacing.xl)
                header
                noticeCard
                Spacer()
                PrimaryButton(
                    title: L10n.Auth.continueButton,
                    systemImage: "arrow.right",
                    action: triggerContinue
                )
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 44, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(AppColors.coffeeBrown)
                .padding(AppSpacing.lg)
                .background(
                    Circle()
                        .fill(AppColors.cardGradient)
                        .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1))
                )
                .shadow(color: AppColors.coffeeBrown.opacity(AppShadow.softOpacity),
                        radius: AppShadow.softRadius,
                        x: 0,
                        y: AppShadow.softYOffset)

            Text(L10n.Auth.title)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
            Text(L10n.Auth.subtitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.md)
        }
    }

    private var noticeCard: some View {
        Text(L10n.Auth.placeholderNotice)
            .font(AppTypography.caption)
            .foregroundStyle(AppColors.textSecondary)
            .multilineTextAlignment(.center)
            .padding(.vertical, AppSpacing.md)
            .padding(.horizontal, AppSpacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(AppColors.beigeSurface.opacity(0.75))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .stroke(AppColors.warmSand.opacity(0.6), lineWidth: 1)
                    )
            )
    }

    private var backdrop: some View {
        ZStack {
            Circle()
                .fill(AppColors.lightCaramel.opacity(0.35))
                .frame(width: 260, height: 260)
                .blur(radius: 90)
                .offset(x: 130, y: -260)
            Circle()
                .fill(AppColors.warmSand.opacity(0.5))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: -130, y: 260)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private func triggerContinue() {
        Task { await viewModel.handleContinue(onSuccess: onAuthenticated) }
    }
}

#Preview {
    AuthView(onAuthenticated: {})
}
