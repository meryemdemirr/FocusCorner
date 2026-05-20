//
//  PrimaryButton.swift
//  FocusCorner
//
//  Premium, caramel-gradient pill button used as the main CTA across the app.
//  Supports an optional loading state that replaces the content with a spinner
//  and disables interaction while in-flight.
//

import SwiftUI

struct PrimaryButton: View {

    let title: LocalizedStringKey
    var systemImage: String? = nil
    var fullWidth: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: triggerAction) {
            ZStack {
                // Stable-size container so the button doesn't jump when
                // switching between content and spinner.
                HStack(spacing: AppSpacing.xs) {
                    Text(title)
                        .font(AppTypography.button)
                    if let systemImage, !isLoading {
                        Image(systemName: systemImage)
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
                .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .tint(AppColors.textOnAccent)
                        .scaleEffect(0.9)
                }
            }
            .foregroundStyle(AppColors.textOnAccent)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.vertical, AppSpacing.md)
            .padding(.horizontal, AppSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.pill, style: .continuous)
                    .fill(AppColors.caramelGradient)
                    .opacity(isLoading ? 0.75 : 1.0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.pill, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    .blendMode(.overlay)
            )
            .shadow(color: AppColors.caramel.opacity(0.35),
                    radius: isPressed ? 6 : 14,
                    x: 0,
                    y: isPressed ? 2 : 8)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .animation(.easeInOut(duration: 0.2), value: isLoading)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isLoading { isPressed = true } }
                .onEnded   { _ in isPressed = false }
        )
        .accessibilityAddTraits(.isButton)
    }

    private func triggerAction() {
        guard !isLoading else { return }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
        action()
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        PrimaryButton(title: "Get Started", systemImage: "arrow.right", action: {})
        PrimaryButton(title: "Signing in…", isLoading: true, action: {})
        PrimaryButton(title: "Next", action: {})
    }
    .padding()
    .background(AppColors.backgroundGradient)
}
