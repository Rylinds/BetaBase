//
//  ContentView.swift
//  BoyerLindsey-Project
//
//  Created by Lindsey Boyer on 11/23/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        NavigationStack(path: $navigationState.path) {
            VStack(spacing: 0) {
                
                // hero image
                Image("hero")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 560)
                    .clipped()
                    .overlay(
                        Text("Welcome to BetaBase")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.top, 50)
                    )
                
                // area below hero image with 'get started'
                VStack(spacing: 24) {
                    Text("Search problems & track your climbs.")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    // custom btn that takes user to the login view
                    NavigationLink(value: "LoginView") {
                        Text("Get Started")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.20, green: 0.40, blue: 0.60))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 4, y: 4)
                            .padding(.horizontal, 100)
                            .offset(y: 40)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .edgesIgnoringSafeArea(.top)
            .navigationDestination(for: String.self) { destination in
                // logic for remembering the user's light/dark preferences for login later
                switch destination {
                case "LoginView":
                    LoginView()
                        .preferredColorScheme(userData.isDarkMode ? .dark : .light)
                case "SearchView":
                    SearchView()
                        .preferredColorScheme(userData.isDarkMode ? .dark : .light)
                default:
                    EmptyView()
                }
            }
            .navigationDestination(for: RouteInfo.self) { route in
                RouteView(route: route)
            }
        }
        // considering the preference is removed when the user logs out, this can probably be written less stupidly since the default is light...
        .preferredColorScheme(userData.isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
        .environmentObject(NavigationState())
        .environmentObject(UserData())
        .environmentObject(NotificationManager.shared)
}
