//
//  AuthTextField.swift
//  FocusCorner
//
//  Reusable, themed text field for authentication forms. Matches the app's
//  warm beige aesthetic with a coffee-brown leading icon, white card surface
//  and optional password reveal toggle.
//

import SwiftUI

struct AuthTextField: View {

    let placeholder: LocalizedStringKey
    let systemImage: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

    @State private var isRevealed: Bool = false

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.coffeeBrown.opacity(0.75))
                .frame(width: 22)

            Group {
                if isSecure && !isRevealed {
                    SecureField(placeholder, text: $text)
                        .textContentType(textContentType)
                } else {
                    TextField(placeholder, text: $text)
                        .textContentType(textContentType)
                        .keyboardType(keyboardType)
                }
            }
            .font(AppTypography.body)
            .foregroundStyle(AppColors.textPrimary)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

            if isSecure {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isRevealed.toggle()
                    }
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(AppColors.textSecondary.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm + 2)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .fill(Color.white.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .stroke(AppColors.warmSand, lineWidth: 1)
                )
        )
        .shadow(color: AppColors.coffeeBrown.opacity(0.04),
                radius: 6, x: 0, y: 2)
    }
}

#Preview {
    @Previewable @State var email = ""
    @Previewable @State var password = ""
    return VStack(spacing: AppSpacing.md) {
        AuthTextField(
            placeholder: "Email address",
            systemImage: "envelope",
            text: $email,
            keyboardType: .emailAddress,
            textContentType: .emailAddress
        )
        AuthTextField(
            placeholder: "Password",
            systemImage: "lock",
            text: $password,
            isSecure: true,
            textContentType: .password
        )
    }
    .padding(AppSpacing.lg)
    .background(AppColors.backgroundGradient)
}
