//
//  Buttons.swift
//  Univestal
//
//  Created by Nathan Egbuna on 11/11/24.
//

import SwiftUI

struct UVButtons: View {
    @ObservedObject var appData: AppData

    // The "Back" and "Next" buttons
    var continueStack: some View {
        HStack {
            backButton
            nextButton
        }
        .padding()
        .onChange(of: appData.onboardingState) {
            appData.updateButtonState()
        }
        .onChange(of: appData.name) {
            appData.updateButtonState()
            if appData.onboardingState == 4 {
                appData.hasAttemptedLogin = false
            }
        }
        .onChange(of: appData.password) {
            appData.updateButtonState()
            if appData.onboardingState == 4 {
                appData.hasAttemptedLogin = false
            }
        }
        .onChange(of: appData.confirmPassword) {
            appData.updateButtonState()
        }
    }

    // Separate view for Back Button
    var backButton: some View {
        Button("Back") {
            withAnimation {
                if appData.onboardingState > 0 && appData.onboardingState != 4 {
                    appData.onboardingState -= 1
                } else {
                    appData.onboardingState = 0
                }
            }
            appData.updateButtonState()
        }
        .foregroundStyle(.white)
        .frame(height: 55)
        .frame(maxWidth: .infinity)
        .background(Color.blue)
        .cornerRadius(20)
    }

    // Separate view for Next Button
    var nextButton: some View {
        Button("Next") {
            withAnimation {
                if appData.onboardingState != 4 && appData.onboardingState != 2 {
                    appData.onboardingState += 1
                } else if appData.onboardingState == 2 {
                    print("Before sign-up: \(appData.password)")
                    appData.signUp()
                    print("After sign-up: \(appData.hashPassword(appData.password))")
                    appData.onboardingState = 3
                } else if appData.onboardingState == 4 {
                    appData.hasAttemptedLogin = true
                    if appData.login() {
                        appData.onboardingState = 3
                    }
                }
            }
            appData.updateButtonState()
        }
        .disabled(appData.isNextButtonDisabled)
        .foregroundStyle(.white)
        .frame(height: 55)
        .frame(maxWidth: .infinity)
        .background(appData.isNextButtonDisabled ? Color.gray : Color.blue)
        .cornerRadius(20)
        .opacity(appData.isNextButtonDisabled ? 0.5 : 1.0)
    }

    // The "Log in" and "Sign up" buttons
    var primaryStack: some View {
        HStack {
            Button("Log in") {
                withAnimation {
                    appData.onboardingState = 4
                    appData.showLoginButton = false
                }
                appData.updateButtonState()
            }
            .foregroundStyle(.white)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(20)

            Button("Sign up") {
                withAnimation {
                    appData.onboardingState = 1
                    appData.showLoginButton = false
                }
                appData.updateButtonState()
            }
            .foregroundStyle(.white)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(20)
        }
        .padding()
    }

    var body: some View {
        VStack {
            if appData.onboardingState == 0 {
                // Primary stack when onboardingState is 0 (before sign-up or log-in)
                primaryStack
            } else {
                // Continue stack for the rest of the onboarding
                continueStack
            }
        }
        .padding()
    }
}
