//
//  AuthView.swift
//  FocusCorner
//
//  Premium email/password authentication screen. Hosts both Login and Register
//  flows in a single view controlled by an animated mode picker. Navigation
//  after a successful action is driven automatically by AppCoordinator's
//  Firebase auth-state listener — no callback is needed.
//

import SwiftUI

// MARK: - Auth mode

private enum AuthMode: CaseIterable, Hashable {
    case login, register

    var title: LocalizedStringKey {
        switch self {
        case .login:    return L10n.Auth.modeLogin
        case .register: return L10n.Auth.modeRegister
        }
    }
}

// MARK: - View

struct AuthView: View {

    @State private var authMode: AuthMode = .login
    @State private var loginVM = LoginViewModel()
    @State private var registerVM = RegisterViewModel()
    @State private var alertError: AuthError? = nil

    @Namespace private var modeNamespace

    var body: some View {
        ZStack {
            AppColors.backgroundGradient.ignoresSafeArea()
            backdrop

            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    logoHeader
                    modePicker
                    formSection
                    Spacer(minLength: AppSpacing.lg)
                    actionButton
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.xxl)
                .padding(.bottom, AppSpacing.xxl)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
        }
        .alert(
            alertError?.alertTitle ?? "",
            isPresented: Binding(get: { alertError != nil }, set: { if !$0 { alertError = nil } })
        ) {
            Button("OK", role: .cancel) { alertError = nil }
        } message: {
            if let error = alertError {
                Text(error.errorDescription ?? "")
            }
        }
        .onChange(of: authMode) { _, _ in
            loginVM.clearError()
            registerVM.clearError()
        }
    }

    // MARK: - Logo header

    private var logoHeader: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.cardGradient)
                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1))
                    .frame(width: 96, height: 96)
                    .shadow(color: AppColors.coffeeBrown.opacity(AppShadow.softOpacity),
                            radius: AppShadow.softRadius,
                            x: 0, y: AppShadow.softYOffset)

                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 40, weight: .light))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(AppColors.coffeeBrown)
            }

            VStack(spacing: AppSpacing.xxs) {
                Text(authMode == .login ? L10n.Auth.loginTitle : L10n.Auth.registerTitle)
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                    .animation(.none, value: authMode)

                Text(authMode == .login ? L10n.Auth.loginSubtitle : L10n.Auth.registerSubtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .animation(.none, value: authMode)
            }
        }
    }

    // MARK: - Mode picker

    private var modePicker: some View {
        HStack(spacing: AppSpacing.xxs) {
            ForEach(AuthMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        authMode = mode
                    }
                } label: {
                    ZStack {
                        if authMode == mode {
                            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                                .fill(AppColors.caramelGradient)
                                .matchedGeometryEffect(id: "mode.selector", in: modeNamespace)
                                .shadow(color: AppColors.caramel.opacity(0.3),
                                        radius: 8, x: 0, y: 4)
                        }

                        Text(mode.title)
                            .font(AppTypography.button)
                            .foregroundStyle(authMode == mode
                                             ? AppColors.textOnAccent
                                             : AppColors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.sm)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppSpacing.xxs)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg + 4, style: .continuous)
                .fill(AppColors.warmSand.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg + 4, style: .continuous)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        )
    }

    // MARK: - Form section

    @ViewBuilder
    private var formSection: some View {
        VStack(spacing: AppSpacing.md) {
            if authMode == .login {
                loginFields
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal:   .move(edge: .trailing).combined(with: .opacity)
                    ))
            } else {
                registerFields
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: authMode)
    }

    private var loginFields: some View {
        VStack(spacing: AppSpacing.md) {
            AuthTextField(
                placeholder: L10n.Auth.emailPlaceholder,
                systemImage: "envelope",
                text: $loginVM.email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )
            AuthTextField(
                placeholder: L10n.Auth.passwordPlaceholder,
                systemImage: "lock",
                text: $loginVM.password,
                isSecure: true,
                textContentType: .password
            )
        }
    }

    private var registerFields: some View {
        VStack(spacing: AppSpacing.md) {
            AuthTextField(
                placeholder: L10n.Auth.emailPlaceholder,
                systemImage: "envelope",
                text: $registerVM.email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )
            AuthTextField(
                placeholder: L10n.Auth.passwordPlaceholder,
                systemImage: "lock",
                text: $registerVM.password,
                isSecure: true,
                textContentType: .newPassword
            )
            AuthTextField(
                placeholder: L10n.Auth.confirmPasswordPlaceholder,
                systemImage: "lock.shield",
                text: $registerVM.confirmPassword,
                isSecure: true,
                textContentType: .newPassword
            )
        }
    }

    // MARK: - Action button

    private var actionButton: some View {
        let isLoading = authMode == .login ? loginVM.isLoading : registerVM.isLoading
        let title: LocalizedStringKey = authMode == .login
            ? L10n.Auth.loginButton
            : L10n.Auth.registerButton

        return PrimaryButton(
            title: title,
            systemImage: isLoading ? nil : "arrow.right",
            isLoading: isLoading,
            action: triggerAction
        )
    }

    // MARK: - Backdrop

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

    // MARK: - Actions

    private func triggerAction() {
        Task {
            switch authMode {
            case .login:
                await loginVM.login()
                if let error = loginVM.authError {
                    alertError = error
                    loginVM.clearError()
                }
            case .register:
                await registerVM.register()
                if let error = registerVM.authError {
                    alertError = error
                    registerVM.clearError()
                }
            }
        }
    }
}

#Preview {
    AuthView()
}
