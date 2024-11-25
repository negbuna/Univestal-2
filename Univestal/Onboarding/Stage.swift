//
//  Stage.swift
//  Univestal
//
//  Created by Nathan Egbuna on 7/6/24.
//

import SwiftUI

struct Stage: View {
    @ObservedObject var appData: AppData // The appData in this context is passed
    
    var body: some View {
        if let isSignedIn = appData.currentUserSignedIn, isSignedIn && !appData.currentUsername.isEmpty {
            HomepageView(appData: appData)
        } else {
            PageViews(appData: appData)
        }
    }
}

#Preview {
    Stage(appData: AppData())
}
