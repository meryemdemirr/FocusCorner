//
//  OnboardingCard.swift
//  FocusCorner
//
//  A single onboarding slide. Renders a floating illustration container with a
//  soft shadow above a centred title + description block.
//

import SwiftUI

struct OnboardingCard: View {

    let page: OnboardingPage
    /// Used to drive a subtle entry animation when the slide becomes visible.
    let isActive: Bool

    @State private var isFloating: Bool = false

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            illustration
            textBlock
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear { startFloating() }
    }

    // MARK: - Illustration

    private var illustration: some View {
        ZStack {
            // Soft ambient glow
            Circle()
                .fill(page.accent.opacity(0.35))
                .frame(width: 280, height: 280)
                .blur(radius: 40)

            // Floating card
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                .fill(AppColors.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
                .frame(width: 240, height: 240)
                .shadow(color: AppColors.coffeeBrown.opacity(AppShadow.softOpacity),
                        radius: AppShadow.softRadius,
                        x: 0,
                        y: AppShadow.softYOffset)

            Image(systemName: page.symbol)
                .font(.system(size: 92, weight: .light))
                .foregroundStyle(AppColors.coffeeBrown)
                .symbolRenderingMode(.hierarchical)
                .scaleEffect(isActive ? 1.0 : 0.92)
                .opacity(isActive ? 1.0 : 0.7)
                .animation(.spring(response: 0.6, dampingFraction: 0.75), value: isActive)
        }
        .offset(y: isFloating ? -6 : 6)
        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true),
                   value: isFloating)
        .accessibilityHidden(true)
    }

    // MARK: - Text

    private var textBlock: some View {
        VStack(spacing: AppSpacing.md) {
            Text(page.title)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(page.description)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, AppSpacing.sm)
        }
        .opacity(isActive ? 1.0 : 0.0)
        .offset(y: isActive ? 0 : 12)
        .animation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.05),
                   value: isActive)
    }

    private func startFloating() {
        // Kick the floating animation on the next runloop so it animates correctly.
        DispatchQueue.main.async { isFloating = true }
    }
}

#Preview {
    OnboardingCard(page: OnboardingPage.all[0], isActive: true)
        .background(AppColors.backgroundGradient.ignoresSafeArea())
}
