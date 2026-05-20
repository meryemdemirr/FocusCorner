//
//  PrimaryButton.swift
//  FocusCorner
//
//  Premium, caramel-gradient pill button used as the main CTA across the app.
//

import SwiftUI

struct PrimaryButton: View {

    let title: LocalizedStringKey
    var systemImage: String? = nil
    var fullWidth: Bool = true
    let action: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: triggerAction) {
            HStack(spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.button)
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .foregroundStyle(AppColors.textOnAccent)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.vertical, AppSpacing.md)
            .padding(.horizontal, AppSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.pill, style: .continuous)
                    .fill(AppColors.caramelGradient)
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
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityAddTraits(.isButton)
    }

    private func triggerAction() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
        action()
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        PrimaryButton(title: "Get Started", systemImage: "arrow.right", action: {})
        PrimaryButton(title: "Next", action: {})
    }
    .padding()
    .background(AppColors.backgroundGradient)
}
