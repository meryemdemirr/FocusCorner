//
//  MainTabView.swift
//  FocusCorner
//
//  Hosts the five tab destinations. Each tab gets its own NavigationStack so
//  push navigation inside one tab does not leak into the others. The system
//  TabView is replaced by a custom FloatingTabBar overlay.
//

import SwiftUI

struct MainTabView: View {

    @State private var selection: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
            FloatingTabBar(selection: $selection)
                .padding(.bottom, AppSpacing.xs)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onAppear {
            PlaceStore.shared.startListening()
        }
    }

    // MARK: - Tab content

    /// Renders the active tab's NavigationStack. Inactive tabs are kept in the
    /// hierarchy via `opacity` so SwiftUI preserves their internal state across
    /// switches, while keeping things lightweight enough for a placeholder app.
    @ViewBuilder
    private var tabContent: some View {
        ZStack {
            stackForTab(.home).opacity(selection == .home ? 1 : 0)
            stackForTab(.map).opacity(selection == .map ? 1 : 0)
            stackForTab(.addPlace).opacity(selection == .addPlace ? 1 : 0)
            stackForTab(.saved).opacity(selection == .saved ? 1 : 0)
            stackForTab(.profile).opacity(selection == .profile ? 1 : 0)
        }
        .animation(.easeInOut(duration: 0.25), value: selection)
    }

    @ViewBuilder
    private func stackForTab(_ tab: AppTab) -> some View {
        NavigationStack {
            switch tab {
            case .home:     HomeView()
            case .map:      MapView()
            case .addPlace: AddPlaceView()
            case .saved:    SavedView()
            case .profile:  ProfileView()
            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppCoordinator())
}
