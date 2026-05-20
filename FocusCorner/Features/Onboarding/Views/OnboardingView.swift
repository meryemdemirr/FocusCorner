//
//  OnboardingView.swift
//  FocusCorner
//
//  Premium 3-page onboarding flow. Driven by `OnboardingViewModel` and built
//  from reusable components in Features/Onboarding/Components.
//

import SwiftUI

struct OnboardingView: View {

    @State private var viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    init() {
        _viewModel = State(initialValue: OnboardingViewModel())
    }

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            decorativeBackdrop

            VStack(spacing: AppSpacing.lg) {
                topBar
                pager
                bottomBar
            }
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.lg)
        }
    }

    // MARK: - Subviews

    /// Soft, ambient blobs sitting behind everything to give the screen a
    /// "lifestyle magazine" feel without competing with the content.
    private var decorativeBackdrop: some View {
        ZStack {
            Circle()
                .fill(AppColors.lightCaramel.opacity(0.35))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: -140, y: -260)

            Circle()
                .fill(AppColors.warmSand.opacity(0.55))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: 160, y: 280)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button {
                viewModel.skip()
            } label: {
                Text(L10n.Onboarding.Actions.skip)
                    .font(AppTypography.button)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xs)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.4))
                    )
            }
            .buttonStyle(.plain)
            .opacity(viewModel.showsSkipButton ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.25), value: viewModel.showsSkipButton)
            .accessibilityHidden(!viewModel.showsSkipButton)
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    private var pager: some View {
        TabView(selection: $viewModel.currentIndex) {
            ForEach(viewModel.pages) { page in
                OnboardingCard(page: page,
                               isActive: viewModel.currentIndex == page.id)
                    .tag(page.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.spring(response: 0.55, dampingFraction: 0.85),
                   value: viewModel.currentIndex)
    }

    private var bottomBar: some View {
        VStack(spacing: AppSpacing.lg) {
            PageIndicator(
                pageCount: viewModel.pages.count,
                currentIndex: viewModel.currentIndex,
                onSelect: { viewModel.go(to: $0) }
            )

            PrimaryButton(
                title: viewModel.primaryActionTitle,
                systemImage: viewModel.isLastPage ? "arrow.right" : nil,
                action: { viewModel.goToNext() }
            )
            .padding(.horizontal, AppSpacing.lg)
            .animation(.spring(response: 0.45, dampingFraction: 0.85),
                       value: viewModel.isLastPage)
        }
    }
}

#Preview("English") {
    OnboardingView()
        .environment(\.locale, .init(identifier: "en"))
}

#Preview("Türkçe") {
    OnboardingView()
        .environment(\.locale, .init(identifier: "tr"))
}
