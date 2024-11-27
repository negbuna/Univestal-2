//
//  HomepageView.swift
//  Univestal
//
//  Created by Nathan Egbuna on 7/6/24.
//

import SwiftUI

struct HomepageView: View {
    @ObservedObject var appData: AppData
    @ObservedObject var crypto: Crypto
    
    @State var isAnimating: Bool = false
    @State var appState: Int = 0 // REMEMBER TO CHANGE THIS BACK TO 0 WHEN SIMULATING
    @State var page: Int = 0
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
    HomepageView(appData: AppData(), crypto: Crypto())
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        appState = 1
                    }
                }
            }
        }
    }
    
    private var homepage: some View {
        TabView(selection: $page) {
            UVHubView(appData: appData)
                .tabItem {
                    Label("Hub", systemImage: "globe")
                }
                .tag(0)
            Search(appData: appData, crypto: crypto)
                .tabItem {
                    Label("Coins", systemImage: "magnifyingglass")
                }
                .tag(1)
            Text("Trading View")
                .tabItem {
                    Label("Trade", systemImage: "chart.bar")
                }
                .tag(2)
            Text("Learn View")
                .tabItem {
                    Label("Learn", systemImage: "puzzlepiece")
                }
                .tag(3)
            UVProfileView(appData: appData)
                .tabItem {
                    Label("Me", systemImage: "person")
                }
                .tag(4)
        }
        .tabViewStyle(DefaultTabViewStyle())
        .edgesIgnoringSafeArea(.bottom)
    }
}
