//
//  PageIndicator.swift
//  FocusCorner
//
//  Animated capsule-style page indicator. The active dot stretches into a
//  pill and uses the brand caramel tone — inactive dots are soft sand.
//

import SwiftUI

struct PageIndicator: View {

    let pageCount: Int
    let currentIndex: Int
    /// Tapping a dot jumps directly to that page.
    var onSelect: ((Int) -> Void)? = nil

    private let dotSize: CGFloat = 8
    private let activeWidth: CGFloat = 26

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index == currentIndex ? AppColors.caramelGradient
                          : LinearGradient(colors: [AppColors.warmSand, AppColors.warmSand],
                                           startPoint: .top, endPoint: .bottom))
                    .frame(width: index == currentIndex ? activeWidth : dotSize,
                           height: dotSize)
                    .onTapGesture { onSelect?(index) }
                    .accessibilityHidden(true)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentIndex)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(
            String.localizedStringWithFormat(
                NSLocalizedString("onboarding.a11y.pageIndicator",
                                  comment: "Onboarding page indicator"),
                currentIndex + 1,
                pageCount
            )
        ))
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        PageIndicator(pageCount: 3, currentIndex: 0)
        PageIndicator(pageCount: 3, currentIndex: 1)
        PageIndicator(pageCount: 3, currentIndex: 2)
    }
    .padding()
    .background(AppColors.backgroundGradient)
}
