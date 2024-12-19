//
//  Stage.swift
//  Univestal
//
//  Created by Nathan Egbuna on 7/6/24.
//

import SwiftUI

struct Stage: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var environment: TradingEnvironment
    @EnvironmentObject var news: News
    
    var body: some View {
        if appData.currentUserSignedIn && !appData.currentUsername.isEmpty {
            HomepageView()
        } else {
            PageViews()
        }
    }
}

#Preview { 
    Stage()
        .environmentObject(AppData())
        .environmentObject(TradingEnvironment.shared)
        .environmentObject(News())
}

