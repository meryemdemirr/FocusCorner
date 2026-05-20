//
//  ContentView.swift
//  FocusCorner
//
//  Top-level entry point. Delegates to RootView which manages the app flow
//  (splash → onboarding → auth → main).
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        RootView()
    }
}

#Preview {
    ContentView()
}
