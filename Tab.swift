//
//  Tab.swift
//  BoyerLindsey-Project
//
//  Created by Lindsey Boyer on 11/25/25.
//

// Nav Bar Tab for the bottom of all main views (search, bookmarks, profile, settings)
import SwiftUI

enum Tab: String, CaseIterable {
    case search = "magnifyingglass"
    case bookmark = "bookmark"
    case profile = "person"
    case settings = "gear"
}

struct TabBar: View {
    // selected icon corresponding to the current screen has the blue color
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.rawValue)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(selectedTab == tab ? Color(red: 0.20, green: 0.40, blue: 0.60) : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .top
        )
    }
    
    // switching for when user taps a different icon on the nav bar
    private func tabTitle(for tab: Tab) -> String {
        switch tab {
        case .search: return "Search"
        case .bookmark: return "Saved"
        case .profile: return "Profile"
        case .settings: return "Settings"
        }
    }
}
