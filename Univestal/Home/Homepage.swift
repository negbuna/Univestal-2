//
//  HomepageView.swift
//  Univestal
//
//  Created by Nathan Egbuna on 7/6/24.
//

import SwiftUI

struct HomepageView: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var environment: TradingEnvironment
    @EnvironmentObject var news: News
    @State var isAnimating: Bool = false
    @State var appState: Int = 0
    @State var page: Int = 0
    
    var body: some View {
        VStack {
            switch appState {
            case 0:
                welcomeSec2
                    .transition(appData.transition)
            case 1:
                homepage
                    .transition(appData.transition)
            default:
                welcomeSec2
                    .transition(appData.transition)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HomepageView()
        .environmentObject(AppData())
        .environmentObject(TradingEnvironment.shared)
        .environmentObject(News())
}

extension HomepageView {
    private var welcomeSec2: some View {
        VStack {
            Text("Welcome")
                .foregroundStyle(.primary)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding()
                .offset(y: isAnimating ? 0 : UIScreen.deviceHeight)
                .opacity(isAnimating ? 1 : 0)
                .frame(
                    width: UIScreen.deviceWidth,
                    height: UIScreen.deviceHeight,
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
    
    private var homepage: some View {
        TabView(selection: $page) {
            UVHubView()
                .tabItem {
                    Label("Hub", systemImage: "globe")
                }
                .tag(0)
            Watchlist()
                .tabItem {
                    Label("Watchlist", systemImage: "star")
                }
                .tag(1)
            TradingView()
                .tabItem {
                    Label("Trade", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
            Learn()
                .tabItem {
                    Label("Learn", systemImage: "puzzlepiece")
                }
                .tag(3)
            UVProfileView()
                .tabItem {
                    Label("Me", systemImage: "person")
                }
                .tag(4)
        }
        .tabViewStyle(DefaultTabViewStyle())
        .edgesIgnoringSafeArea(.bottom)
    }
}
