//
//  UVSettingsView.swift
//  Univestal
//
//  Created by Nathan Egbuna on 7/7/24.
//

import SwiftUI

struct UVSettingsView: View {
    @ObservedObject var appData: AppData
    
    @State private var showAlertSignout: Bool = false
    @State private var showAlertDelete: Bool = false
        
    var body: some View {
        NavigationView {
            ZStack {
                ColorManager.bkgColor
                    .ignoresSafeArea()
                List {
                    Section(header: Text("App")) {
                        NavigationLink(destination: PrivacyPolicy()) {
                            Text("Privacy Policy")
                        }
                        NavigationLink(destination: Review()) {
                            Text("Leave a Review")
                        }
                    }
                    
                    Section(header: Text("Profile")) {
                        Button(action: {
                            showAlertSignout.toggle()
                        }) {
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                        .alert(isPresented: $showAlertSignout) {
                            Alert(
                                title: Text("Are you sure?"),
                                primaryButton: .cancel(Text("Stay Signed In")),
                                secondaryButton: .destructive(Text("Sign Out")) {
                                    appData.signOut()
                                }
                            )
                        }
                        
                        Button(action: {
                            showAlertDelete.toggle()
                        }) {
                            Text("Delete Account")
                                .foregroundColor(.red)
                        }
                        .alert(isPresented: $showAlertDelete) {
                            Alert(
                                title: Text("Are you sure you want to delete your account?"),
                                message: Text("This action cannot be undone."),
                                primaryButton: .cancel(Text("No")),
                                secondaryButton: .destructive(Text("Delete Account")) {
                                    appData.deleteAccount()
                                }
                            )
                        }
                    } // end section header
                } // end list
                .navigationTitle("Settings")
            }
        } // end nav stack
    } // end body
}

#Preview {
    UVSettingsView(appData: AppData())
}
