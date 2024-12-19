//
//  Pages.swift
//  Univestal
//
//  Created by Nathan Egbuna on 11/11/24.
//

import SwiftUI

struct PageViews: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var environment: TradingEnvironment
    @State var showPrimary: Bool = false
    @State var showContinue: Bool = false
    
    var obb: UVButtons {
        UVButtons()
    }
    
    private var welcomeSec: some View {
        VStack {
            ZStack {
                ColorManager.bkgColor
                    .ignoresSafeArea()

                Text("Univestal")
                    .foregroundStyle(.primary)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding()
                    .offset(y: showPrimary ? 0 : UIScreen.relativeHeight(50)) // 50% of screen height
                    .opacity(showPrimary ? 1 : 0)
                    .frame(width: UIScreen.deviceWidth, alignment: .center)
            }
            .onAppear {
                showContinue = false
                withAnimation(.easeOut(duration: 2)) {
                    showPrimary = true
                }
            }
        }
    }

    private var addNameSec: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("Create a username:")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                TextField("Username (max 16 characters)", text: $appData.name)
                    .font(.headline)
                    .onChange(of: appData.name) {
                        // Allows only letters, numbers, and underscores
                        let filtered = appData.name.filter { $0.isLetter || $0.isNumber || $0 == "_" }
                        // Update the name only if filtered text is different
                        if filtered != appData.name {
                            appData.name = filtered
                        }
                        // Limit the name length to 16 characters
                        if appData.name.count > 16 {
                            appData.name = String(appData.name.prefix(16))
                        }
                        
                        appData.isButtonDisabled = !appData.validateUsername() || appData.name.count < 3 || appData.name.count > 16
                    }
                
                if appData.name.count < 3 && !appData.name.isEmpty {
                    Text("Username must be at least 3 characters.")
                        .font(.caption)
                        .foregroundStyle(.red)
                } else if appData.name.count <= 3 && appData.isUsernameTaken(appData.name) {
                    Text("Username is unavailable.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                
            }
            .padding()
            .onAppear {
                showPrimary = false
                withAnimation(.easeOut(duration: 2)) {
                    showContinue = true
                }
            }
            .globeOverlay()
        }
    }

    private var addPasswordSec: some View {
        VStack(alignment: .leading) {
            Text("Create a password:")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            SecureField("Password (min 6 characters)", text: $appData.password)
                .font(.headline)
            SecureField("Confirm Password", text: $appData.confirmPassword)
                .font(.headline)
            if appData.password.count < 6 && !appData.password.isEmpty {
                Text("Password must be at least 6 characters.")
                    .font(.caption)
                    .foregroundStyle(.red)
            } else if appData.password != appData.confirmPassword {
                Text("Passwords do not match.")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .globeOverlay()
    }

    private var loginSec: some View {
        VStack(alignment: .leading) {
            Text("Log in")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            TextField("Username", text: $appData.name)
                .font(.headline)
            SecureField("Password", text: $appData.password)
                .font(.headline)
            if appData.hasAttemptedLogin {
                if !appData.name.isEmpty && !appData.isUsernameTaken(appData.name) || (!appData.password.isEmpty && !appData.isPasswordCorrect(username: appData.name, password: appData.password)) {
                    Text("Incorrect username and/or password.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .globeOverlay()
    }
    
    // Page switches based on onboardingState
    var body: some View {
        VStack {
            switch appData.onboardingState {
            case 0:
                welcomeSec
            case 1:
                addNameSec
            case 2:
                addPasswordSec
            case 3:
                // Confirmation screen
                HomepageView()
            case 4:
                loginSec
            default:
                welcomeSec
            }
            
            Spacer()
            
            if appData.onboardingState > 0 && appData.onboardingState <= 2 || appData.onboardingState == 4 {
                obb.continueStack
            } else if appData.onboardingState == 0 {
                obb.primaryStack
            }
        }
        .background(ColorManager.bkgColor)
    }
}

#Preview {
    PageViews()
        .environmentObject(AppData())
        .environmentObject(TradingEnvironment.shared)
}

// Trying overlay as a var in a different way
struct GlobeOverlay: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(alignment: .trailing) {  // Changed to .trailing
                Image(systemName: "globe")
                    .foregroundStyle(.primary)
                    .opacity(0.07)
                    .font(.system(size: UIScreen.main.bounds.width * 3))
                    .offset(x: 2 * (UIScreen.main.bounds.width) , y: 200)
                    .ignoresSafeArea()
            }
    }
}

extension View {
    func globeOverlay() -> some View {
        self.modifier(GlobeOverlay())
    }
}
