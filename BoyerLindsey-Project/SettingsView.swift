//
//  SettingsView.swift
//  BoyerLindsey-Project
//
//  Created by Lindsey Boyer on 11/24/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var notificationManager: NotificationManager

    @State private var showDeleteAlert = false
    @State private var showFeedbackAlert = false
    @State private var showHelpAlert = false
    @State private var selectedTab: Tab = .settings
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                            
                    // view title
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.top, 20)
                        .padding(.horizontal)
                            
                    // dark mode toggle
                    HStack {
                        Text("Dark Mode")
                            .font(.system(size: 18))
                                
                        Spacer()
                                
                        Toggle("", isOn: $userData.isDarkMode)
                            .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.20, green: 0.40, blue: 0.60)))
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 16)
                            
                        Rectangle()
                            .fill(Color.primary.opacity(0.2))
                            .frame(height: 0.5)
                            .padding(.horizontal)
                            
                    // notif toggle
                    HStack {
                        Text("Notifications")
                            .font(.system(size: 18))
                                
                        Spacer()
                                
                        Toggle("", isOn: $notificationManager.notificationsEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.20, green: 0.40, blue: 0.60)))
                            .onChange(of: notificationManager.notificationsEnabled) { _, newValue in notificationManager.toggleNotifications(newValue)
                                }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                            
                    Rectangle()
                        .fill(Color.primary.opacity(0.2))
                        .frame(height: 0.5)
                        .padding(.horizontal)
                    
                    // other settings buttons
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // feedback
                        settingsRow(title: "Send Feedback") {
                            showFeedbackAlert = true
                        }
                        
                        Rectangle()
                            .fill(Color.primary.opacity(0.2))
                            .frame(height: 0.5)
                        
                        // help
                        settingsRow(title: "Help") {
                            showHelpAlert = true
                        }
                        
                        Rectangle()
                            .fill(Color.primary.opacity(0.2))
                            .frame(height: 0.5)
                        
                        // delete account (destructive)
                        settingsRow(title: "Delete Account",
                                    titleColor: .red,
                                    showArrow: true) {
                            showDeleteAlert = true
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 64)
                    
                    Spacer()
                    
                    // sign-out btn
                    Button(action: {
                        userData.signOut()
                        navigateToRoot()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(red: 0.20, green: 0.40, blue: 0.60))
                            .cornerRadius(26)
                            .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 40)
                }
                Spacer()
                    .frame(height: 60)
            }
            // nav tab bar at the bottom
            TabBar(selectedTab: $selectedTab)
                .background(Color(.systemBackground))
        }
        .navigationBarHidden(true)
        .onChange(of: selectedTab) { oldValue, newValue in
            handleTabSelection(newValue)
        }
        
        // MARK: 'Send Feedback' Alert
        .alert("Feedback", isPresented: $showFeedbackAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please route all feedback to the Canvas Assignment comments. Hopefully this project does decently.")
        }
        
        // MARK: 'Help' Alert
        .alert("Help", isPresented: $showHelpAlert) {
            Button("Yikes", role: .none) {
                print("User selected Yikes")
            }
            Button("Nevermind", role: .cancel) {
                print("User selected Nevermind")
            }
        } message: {
            Text("Have you tried turning it off and on again?")
        }
        
        // MARK: 'Delete Account' Alert
        .alert("Delete Account?",
               isPresented: $showDeleteAlert) {
            
            Button("Cancel", role: .cancel) {}
            
            Button("Delete", role: .destructive) {
                Task {
                    await deleteAccountAndReturn()
                }
            }
            
        } message: {
            Text("Are you sure you want to delete your account? This action is permanent and all of your data will be removed.")
        }
    }
    
    // MARK: Nav Bar Icons
    private func handleTabSelection(_ tab: Tab) {
        switch tab {
        case .search:
            // go to search view
            navigateToSearch()
        case .bookmark:
            // go to bookmark view
            navigateToBookmark()
        case .profile:
            // go to profile view
            navigateToProfile()
        case .settings:
            // Already here - do nothing
            break
        }
    }
    
    // MARK: Search View Nav Helper
    private func navigateToSearch() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let searchView = SearchView()
                .environmentObject(userData)
                .environmentObject(NavigationState())
                .preferredColorScheme(userData.isDarkMode ? .dark : .light)
            
            window.rootViewController = UIHostingController(rootView: searchView)
        }
    }
    
    // MARK: Profile View Nav Helper
    private func navigateToProfile() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let profileView = ProfileView()
                .environmentObject(userData)
                .environmentObject(NavigationState())
                .preferredColorScheme(userData.isDarkMode ? .dark : .light)
            
            window.rootViewController = UIHostingController(rootView: profileView)
        }
    }
    
    // MARK: Bookmark View Nav Helper
    private func navigateToBookmark() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let bookmarkView = BookmarkView()
                .environmentObject(userData)
                .environmentObject(NavigationState())
                .preferredColorScheme(userData.isDarkMode ? .dark : .light)
            
            window.rootViewController = UIHostingController(rootView: bookmarkView)
        }
    }
    
    // MARK: Settings Btn Row (Recycled)
    private func settingsRow(title: String,
                             titleColor: Color = .primary,
                             showArrow: Bool = false,
                             action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 18))
                    .foregroundColor(titleColor)
                
                Spacer()
                
                if showArrow {
                    Image(systemName: "chevron.right")
                        .foregroundColor(titleColor)
                }
            }
            .frame(height: 50)
        }
    }
    
    // MARK: Delete Account
    private func deleteAccountAndReturn() async {
        do {
            try await userData.deleteAccount()
            await MainActor.run {
                navigateToRoot()
            }
        } catch {
            print("Delete account error: \(error)")
        }
    }
    
    // MARK: Nav to Content View (Root)
    private func navigateToRoot() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let contentView = ContentView()
                .environmentObject(NavigationState())
                .environmentObject(userData)
                
            window.rootViewController = UIHostingController(rootView: contentView)
            
            UIView.transition(with: window,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: nil,
                            completion: nil)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserData())
        .environmentObject(NotificationManager.shared)
}
