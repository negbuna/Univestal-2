//
//  UVHubView.swift
//  Univestal
//
//  Created by Nathan Egbuna on 7/7/24.
//

import SwiftUI

struct UVHubView: View {
    @ObservedObject var appData: AppData
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                ZStack {
                    
                    ColorManager.bkgColor
                        .ignoresSafeArea()
                    
                    VStack {
                        Text("Recommended")
                            .foregroundStyle(.primary)
                            .font(.headline)
                            .padding()
                        
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 300, height:200)
                            .foregroundStyle(Color(UIColor.systemBackground))
                            .shadow(color: .primary.opacity(1), radius: 10)
                        
                        Spacer()
                        
                        Text("News")
                            .foregroundStyle(.primary)
                            .font(.headline)
                            .padding()
                        
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 300, height:200)
                            .foregroundStyle(Color(UIColor.systemBackground))
                            .shadow(color: .primary.opacity(1), radius: 10)
                        
                        Text("Exchange Rates")
                            .foregroundStyle(.primary)
                            .font(.headline)
                            .padding()
                        
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 300, height:200)
                            .foregroundStyle(Color(UIColor.systemBackground))
                            .shadow(color: .primary.opacity(1), radius: 10)
                        
                        
                    } // end vstack
                    
                } // end zstack
                
            } // end scrollview
            .navigationTitle("Hub")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: UVSettingsView(appData: appData)) {
                                Image(systemName: "gearshape.fill")
                            }
                }
            }
        }
    }
}

struct UVHubView_Previews: PreviewProvider {
    @State static private var currentPage = 0 // Example state for preview
    
    static var previews: some View {
        UVHubView(appData: AppData())
    }
}
