//
//  BookmarkView.swift
//  BoyerLindsey-Project
//
//  Created by Lindsey Boyer on 11/25/25.
//


import SwiftUI

struct BookmarkView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var searchText = ""
    @State private var selectedTab: Tab = .bookmark
    @State private var selectedRoute: RouteInfo? = nil // For route navigation
    
    // get user's bookmarks data
    var filteredBookmarks: [RouteInfo] {
        if searchText.isEmpty {
            return userData.bookmarkedClimbs
        } else {
            return userData.bookmarkedClimbs.filter { $0.route_name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    // view title
                    Text("Saved Routes")
                        .font(.system(size: 24, weight: .semibold))
                        .padding(.top, 20)
                    
                    // search bar
                    TextField("Search bookmarks…", text: $searchText)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .padding(.vertical)
                    
                    // bookmarked routes list
                    if filteredBookmarks.isEmpty {
                        VStack {
                            Spacer()
                            if searchText.isEmpty {
                                Text("No bookmarked routes yet")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                            } else {
                                Text("No matching bookmarks")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                ForEach(filteredBookmarks) { route in
                                    Button(action: {
                                        selectedRoute = route
                                    }) {
                                        RouteCard(route: route)
                                    }
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
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
        .sheet(item: $selectedRoute) { route in
            RouteView(route: route)
                .preferredColorScheme(userData.isDarkMode ? .dark : .light)
        }
    }
    
    // MARK: Nav Bar Icons
    private func handleTabSelection(_ tab: Tab) {
        switch tab {
        case .search:
            // go to search view
            navigateToSearch()
        case .bookmark:
            // already here - do nothing
            break
        case .profile:
            // go to profile view
            navigateToProfile()
        case .settings:
            // go to settings view
            navigateToSettings()
        }
    }
    
    // MARK: Route View Nav Helper
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
    
    // MARK: Settings View Nav Helper
    private func navigateToSettings() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let settingsView = SettingsView()
                .environmentObject(userData)
                .environmentObject(NotificationManager.shared)
                .environmentObject(NavigationState())
                .preferredColorScheme(userData.isDarkMode ? .dark : .light)
            
            window.rootViewController = UIHostingController(rootView: settingsView)
        }
    }
}

#Preview {
    BookmarkView()
        .environmentObject(UserData())
        .environmentObject(NotificationManager.shared)
}
