//
//  SplashView.swift
//  FocusCorner
//
//  Brief, ambient brand splash. Animates in, holds for a beat, then asks the
//  coordinator to advance to the next stage of the flow.
//

import SwiftUI

struct SplashView: View {

    let onFinished: () -> Void

    @State private var hasAppeared: Bool = false

    /// How long the splash lingers before handing off.
    private let holdDuration: Duration = .milliseconds(1400)

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            ambientGlow

            VStack(spacing: AppSpacing.lg) {
                logoMark
                    .scaleEffect(hasAppeared ? 1.0 : 0.85)
                    .opacity(hasAppeared ? 1.0 : 0.0)

                VStack(spacing: AppSpacing.xs) {
                    Text(L10n.Splash.appName)
                        .font(AppTypography.display)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(L10n.Splash.tagline)
                        .font(AppTypography.subtitle)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .multilineTextAlignment(.center)
                .opacity(hasAppeared ? 1.0 : 0.0)
                .offset(y: hasAppeared ? 0 : 10)
            }
            .padding(.horizontal, AppSpacing.xl)
            .animation(.spring(response: 0.7, dampingFraction: 0.85), value: hasAppeared)
        }
        .task { await runIntro() }
    }

    // MARK: - Subviews

    private var logoMark: some View {
        ZStack {
            Circle()
                .fill(AppColors.cardGradient)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
                .frame(width: 132, height: 132)
                .shadow(color: AppColors.coffeeBrown.opacity(AppShadow.softOpacity),
                        radius: AppShadow.softRadius,
                        x: 0,
                        y: AppShadow.softYOffset)

            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 56, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(AppColors.coffeeBrown)
        }
    }

    private var ambientGlow: some View {
        ZStack {
            Circle()
                .fill(AppColors.lightCaramel.opacity(0.4))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: -110, y: -180)

            Circle()
                .fill(AppColors.warmSand.opacity(0.55))
                .frame(width: 360, height: 360)
                .blur(radius: 100)
                .offset(x: 130, y: 240)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    // MARK: - Lifecycle

    private func runIntro() async {
        hasAppeared = true
        try? await Task.sleep(for: holdDuration)
        onFinished()
    }
}

#Preview {
    SplashView(onFinished: {})
}
