//
//  ProfileView.swift
//  BoyerLindsey-Project
//
//  Created by Lindsey Boyer on 11/24/25.
//

import SwiftUI
import Charts

struct ProfileView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var selectedTab: Tab = .profile
    @State private var showFullTickList = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // view title
                        Text("Your Climbs")
                            .font(.system(size: 28, weight: .bold))
                            .padding(.top, 10)
                        
                        // chart of grade distribution of ticked climbs
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Grade Distribution")
                                .font(.headline)
                            
                            if userData.tickedClimbs.isEmpty {
                                Text("No climbs ticked yet.")
                                    .foregroundColor(.gray)
                            // populate with user tick data
                            } else {
                                Chart(gradeCountData) { item in
                                    BarMark(
                                        x: .value("Grade", item.grade),
                                        y: .value("Count", item.count)
                                    )
                                    .foregroundStyle(Color(red: 0.20, green: 0.40, blue: 0.60))
                                }
                                .frame(height: 230)
                            }
                        }
                        
                        // recent ticks (only 10)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Ticks")
                                .font(.headline)
                            
                            if recentTicks.isEmpty {
                                Text("No ticks yet.")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(recentTicks) { route in
                                    RouteCard(route: route)
                                }
                            }
                            
                            // custom button to see full tick list
                            Button(action: {
                                showFullTickList = true
                            }) {
                                Text("View All Ticks")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 0.20, green: 0.40, blue: 0.60))
                                    .cornerRadius(14)
                            }
                            .padding(.top, 8)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                Spacer()
                    .frame(height: 60)
            }
            
            // nav bar at bottom
            TabBar(selectedTab: $selectedTab)
                .background(Color(.systemBackground))
        }
        .navigationBarHidden(true)
        .onChange(of: selectedTab) { oldValue, newValue in
            handleTabSelection(newValue)
        }
        // sheet view of full tick list (back btn or swipe down to dismiss)
        .sheet(isPresented: $showFullTickList) {
            FullTickListView()
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
            // already here - nothing
            break
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
                .environmentObject(userData) // Pass UserData
                .environmentObject(NavigationState())
                .preferredColorScheme(userData.isDarkMode ? .dark : .light)
            
            window.rootViewController = UIHostingController(rootView: searchView)
        }
    }

    // MARK: Settings View Nav Helper
    private func navigateToSettings() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let settingsView = SettingsView()
                .environmentObject(userData)
                .environmentObject(NavigationState())
                .environmentObject(NotificationManager.shared)
                .preferredColorScheme(userData.isDarkMode ? .dark : .light)
            
            window.rootViewController = UIHostingController(rootView: settingsView)
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


    // MARK: Recent 10 Ticks
    var recentTicks: [RouteInfo] {
        Array(userData.tickedClimbs.prefix(10))
    }

    // MARK: Grade Count (Chart Helper)
    var gradeCountData: [GradeCount] {
        let grouped = Dictionary(grouping: userData.tickedClimbs, by: { $0.nopm_YDS.isEmpty ? "Unknown" : $0.nopm_YDS })
        return grouped.map { GradeCount(grade: $0.key, count: $0.value.count) }
            .sorted { $0.grade < $1.grade }
    }
}

struct GradeCount: Identifiable {
    let id = UUID()
    let grade: String
    let count: Int
}

#Preview {
    ProfileView()
        .environmentObject(UserData())
        .environmentObject(NotificationManager.shared)
}
