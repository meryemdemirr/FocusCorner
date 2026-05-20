//
//  FeaturePlaceholderScreen.swift
//  FocusCorner
//
//  Reusable, cozy placeholder used by every tab while the real features are
//  still being built. Provides the navigation chrome, hero illustration and
//  copy each placeholder needs so the screens stay one-screen-only.
//

import SwiftUI

struct FeaturePlaceholderScreen<Footer: View>: View {

    let symbol: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let placeholder: LocalizedStringKey
    @ViewBuilder var footer: () -> Footer

    @State private var hasAppeared: Bool = false

    init(symbol: String,
         title: LocalizedStringKey,
         subtitle: LocalizedStringKey,
         placeholder: LocalizedStringKey,
         @ViewBuilder footer: @escaping () -> Footer = { EmptyView() }) {
        self.symbol = symbol
        self.title = title
        self.subtitle = subtitle
        self.placeholder = placeholder
        self.footer = footer
    }

    var body: some View {
        ZStack {
            AppColors.backgroundGradient.ignoresSafeArea()
            backdrop

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    illustration
                    titleBlock
                    placeholderCard
                    footer()
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.xl)
                // Leave room for the floating tab bar.
                .padding(.bottom, AppSpacing.xxl + AppSpacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear { hasAppeared = true }
    }

    // MARK: - Subviews

    private var illustration: some View {
        ZStack {
            Circle()
                .fill(AppColors.lightCaramel.opacity(0.35))
                .frame(width: 180, height: 180)
                .blur(radius: 40)

            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                .fill(AppColors.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
                .frame(width: 140, height: 140)
                .shadow(color: AppColors.coffeeBrown.opacity(AppShadow.softOpacity),
                        radius: AppShadow.softRadius,
                        x: 0,
                        y: AppShadow.softYOffset)

            Image(systemName: symbol)
                .font(.system(size: 56, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(AppColors.coffeeBrown)
        }
        .scaleEffect(hasAppeared ? 1.0 : 0.92)
        .opacity(hasAppeared ? 1.0 : 0.0)
        .animation(.spring(response: 0.65, dampingFraction: 0.85), value: hasAppeared)
    }

    private var titleBlock: some View {
        VStack(spacing: AppSpacing.xs) {
            Text(title)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, AppSpacing.sm)
        .opacity(hasAppeared ? 1.0 : 0.0)
        .offset(y: hasAppeared ? 0 : 8)
        .animation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.05),
                   value: hasAppeared)
    }

    private var placeholderCard: some View {
        Text(placeholder)
            .font(AppTypography.body)
            .foregroundStyle(AppColors.textSecondary)
            .multilineTextAlignment(.center)
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(AppColors.beigeSurface.opacity(0.75))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                            .stroke(AppColors.warmSand.opacity(0.6), lineWidth: 1)
                    )
            )
            .shadow(color: AppColors.coffeeBrown.opacity(AppShadow.softOpacity * 0.6),
                    radius: AppShadow.softRadius,
                    x: 0,
                    y: AppShadow.softYOffset)
            .opacity(hasAppeared ? 1.0 : 0.0)
            .offset(y: hasAppeared ? 0 : 14)
            .animation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.12),
                       value: hasAppeared)
    }

    private var backdrop: some View {
        ZStack {
            Circle()
                .fill(AppColors.lightCaramel.opacity(0.3))
                .frame(width: 260, height: 260)
                .blur(radius: 90)
                .offset(x: -140, y: -260)
            Circle()
                .fill(AppColors.warmSand.opacity(0.5))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: 150, y: 280)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

#Preview {
    FeaturePlaceholderScreen(
        symbol: "sun.horizon.fill",
        title: "Good morning",
        subtitle: "Discover your next favorite spot to focus today.",
        placeholder: "Curated cafes and workspaces will appear here."
    )
}
