//
//  HomepageView.swift
//  Univestal
//
//  Created by Nathan Egbuna on 7/6/24.
//

import SwiftUI

struct HomepageView: View {
    @ObservedObject var appData: AppData
    
    @State private var isAnimating: Bool = false
    @State private var appState: Int = 0
    @State private var lastPage: Int = 0
    let transition: AnyTransition = .asymmetric(
        insertion: .move(edge: .trailing),
        removal: .move(edge: .leading))
    
    var body: some View {
        VStack {
            switch appState {
            case 0:
                welcomeSec2
                    .transition(transition)
            case 1:
                homepage
                    .transition(transition)
            default:
                welcomeSec2
                    .transition(transition)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HomepageView(appData: AppData())
}

extension HomepageView {
    private var welcomeSec2: some View {
        GeometryReader { geometry in
            VStack {
                Text("Welcome")
                    .foregroundStyle(.primary)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding()
                    .offset(y: isAnimating ? 0 : geometry.size.height)
                    .opacity(isAnimating ? 1 : 0)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height,
                        alignment: .center)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 2)) {
                    isAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    withAnimation {
                        appState = 1
                    }
                }
            }
        }
    }
    
    private var homepage: some View {
        TabView(selection: $lastPage) {
            UVHubView(appData: appData)
                .tabItem {
                    Label("Hub", systemImage: "globe")
                        .tag(0)
                }
            Text("Search View")
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                        .tag(1)
                }
            Text("Watchlist View")
                .tabItem {
                    Label("Watchlist", systemImage: "star")
                        .tag(2)
                }
            Text("Trading View")
                .tabItem {
                    Label("Trade", systemImage: "chart.line.uptrend.xyaxis")
                        .tag(3)
                }
            UVProfileView(appData: appData)
                .tabItem {
                    Label("Me", systemImage: "person")
                        .tag(4)
                }
        }
        .tabViewStyle(DefaultTabViewStyle())
        .edgesIgnoringSafeArea(.bottom)
    }
}
