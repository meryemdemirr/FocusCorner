//
//  FloatingTabBar.swift
//  FocusCorner
//
//  Custom Apple-inspired floating tab bar. Lives above the content with a
//  soft blur background, beige tint, gentle shadow and an animated selection
//  indicator. The "Add" tab is rendered as a prominent centre action.
//

import SwiftUI

struct FloatingTabBar: View {

    @Binding var selection: AppTab
    /// Triggered when the prominent centre action is tapped — the host can
    /// decide whether to switch tabs, present a sheet, etc.
    var onPrimaryAction: (() -> Void)? = nil

    @Namespace private var selectionNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                if tab.isPrimaryAction {
                    primaryActionButton(for: tab)
                } else {
                    tabButton(for: tab)
                }
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(barBackground)
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Buttons

    @ViewBuilder
    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = tab == selection
        Button {
            select(tab)
        } label: {
            VStack(spacing: 2) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(AppColors.caramelGradient.opacity(0.18))
                            .matchedGeometryEffect(id: "tab.indicator",
                                                   in: selectionNamespace)
                            .frame(width: 46, height: 32)
                    }
                    Image(systemName: tab.symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(isSelected
                                         ? AppColors.coffeeBrown
                                         : AppColors.textSecondary.opacity(0.7))
                        .scaleEffect(isSelected ? 1.06 : 1.0)
                }
                .frame(height: 34)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium,
                                  design: .rounded))
                    .foregroundStyle(isSelected
                                     ? AppColors.coffeeBrown
                                     : AppColors.textSecondary.opacity(0.75))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(tab.title))
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }

    @ViewBuilder
    private func primaryActionButton(for tab: AppTab) -> some View {
        Button {
            triggerPrimaryAction(tab: tab)
        } label: {
            ZStack {
                Circle()
                    .fill(AppColors.caramelGradient)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.4), lineWidth: 1)
                            .blendMode(.overlay)
                    )
                    .shadow(color: AppColors.caramel.opacity(0.45),
                            radius: 12, x: 0, y: 6)

                Image(systemName: tab.symbol)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppColors.textOnAccent)
            }
            .frame(width: 54, height: 54)
            .offset(y: -10)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .accessibilityLabel(Text(tab.title))
    }

    // MARK: - Background

    private var barBackground: some View {
        RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .fill(AppColors.creamBackground.opacity(0.75))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .stroke(Color.white.opacity(0.55), lineWidth: 1)
            )
            .shadow(color: AppColors.coffeeBrown.opacity(0.15),
                    radius: 18, x: 0, y: 8)
    }

    // MARK: - Actions

    private func select(_ tab: AppTab) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            selection = tab
        }
    }

    private func triggerPrimaryAction(tab: AppTab) {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
        if let onPrimaryAction {
            onPrimaryAction()
        } else {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                selection = tab
            }
        }
    }
}

#Preview {
    @Previewable @State var selection: AppTab = .home
    return ZStack {
        AppColors.backgroundGradient.ignoresSafeArea()
        VStack {
            Spacer()
            FloatingTabBar(selection: $selection)
                .padding(.bottom, AppSpacing.md)
        }
    }
}
