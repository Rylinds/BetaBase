//
//  SearchView.swift
//  BoyerLindsey-Project
//
//  Created by Lindsey Boyer on 11/23/25.
//

import SwiftUI
import FirebaseFirestore

// route info imported to Firestore from github: OpenBeta/climbing-data
struct RouteInfo: Identifiable, Codable, Hashable {
    var id: String
    var route_name: String
    var type_string: String
    var parent_sector: String
    var mean_rating: Double
    var nopm_YDS: String
    var state: String
    var description: String
    var location: String
    var num_votes: Int
    var safety: String
}

struct SearchView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var searchText = ""
    @State private var results: [RouteInfo] = []
    @State private var selectedRoute: RouteInfo? = nil
    @State private var selectedTab: Tab = .search
    private let db = Firestore.firestore()

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    // screen title
                    Text("Routes")
                        .font(.system(size: 24, weight: .semibold))
                        .padding(.top, 20)

                    // search bar
                    TextField("Search routes…", text: $searchText)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .padding(.vertical)
                        .onChange(of: searchText) {
                            runSearch()
                        }

                    // route results that populate from imported dataset
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(results) { route in
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
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: 60)
            }
            
            // nav tab bar at the bottom of the screen
            TabBar(selectedTab: $selectedTab)
                .background(Color(.systemBackground))
        }
        // handles navigation when user taps an icon
        .navigationBarHidden(true)
        .onChange(of: selectedTab) { oldValue, newValue in
            handleTabSelection(newValue)
        }
        // sheet view of route w/ info when user selects a route card
        .sheet(item: $selectedRoute) { route in
            RouteView(route: route)
                .preferredColorScheme(userData.isDarkMode ? .dark : .light)
        }
        .preferredColorScheme(userData.isDarkMode ? .dark : .light)
    }

    // MARK: Nav Bar Icons
    private func handleTabSelection(_ tab: Tab) {
        switch tab {
        case .search:
            // currently here
            break
        case .bookmark:
            // go to bookmark view
            navigateToBookmark()
        case .profile:
            // go to profile view
            navigateToProfile()
        case .settings:
            // go to settings view
            navigateToSettings()
        }
    }
    
    // MARK: Route View Nav Helper
    private func navigateToRoute(_ route: RouteInfo) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let routeView = RouteView(route: route)
                .environmentObject(userData)
                .environmentObject(NavigationState())
                .preferredColorScheme(userData.isDarkMode ? .dark : .light)
            
            window.rootViewController = UIHostingController(rootView: routeView)
        }
    }
    
    // MARK: Profile View Nav Helper
    private func navigateToProfile() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let profileView = ProfileView()
                .environmentObject(userData) // Make sure to pass UserData
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
                .environmentObject(userData) // Make sure to pass UserData
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

    // MARK: Firestore Search Query
    func runSearch() {
        // do nothing if the search bar text is empty
        guard !searchText.isEmpty else {
            results = []
            return
        }

        // get the route data
        db.collection("routes").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching routes: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                results = []
                return
            }

            // filter using 'contains' (case-insensitive)
            results = documents.compactMap { doc in
                let data = doc.data()
                let routeName = (data["route_name"] as? String ?? "").lowercased()
                
                if routeName.contains(searchText.lowercased()) {
                    // route info returned to match that earlier struct
                    return RouteInfo(
                        id: doc.documentID,
                        route_name: data["route_name"] as? String ?? "",
                        type_string: data["type_string"] as? String ?? "",
                        parent_sector: data["parent_sector"] as? String ?? "",
                        mean_rating: data["mean_rating"] as? Double ?? 0.0,
                        nopm_YDS: data["nopm_YDS"] as? String ?? "",
                        state: data["state"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        location: data["location"] as? String ?? "",
                        num_votes: data["num_votes"] as? Int ?? 0,
                        safety: data["safety"] as? String ?? ""
                    )
                } else {
                    return nil
                }
            }
            //print("Found \(results.count) routes matching '\(searchText)'")
        }
    }
}

// MARK: Route Card
struct RouteCard: View {
    let route: RouteInfo

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color(.systemGray6))
                .frame(height: 90)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
            VStack(alignment: .leading, spacing: 6) {
                
                // route name and YDS (yosemite decimal system (route grade))
                HStack {
                    Text(route.route_name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)

                    Spacer()

                    Text(route.nopm_YDS)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                }

                // route type and vote rating
                HStack {
                    Text(route.type_string.capitalized)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)

                    Spacer()

                    Text("\(String(format: "%.1f", route.mean_rating)) stars")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                }

                // state > parent sector
                Text("\(route.state) > \(route.parent_sector)")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(UserData())
        .environmentObject(NotificationManager.shared)
}
