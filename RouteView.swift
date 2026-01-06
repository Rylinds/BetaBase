//
//  RouteView.swift
//  BoyerLindsey-Project
//
//  Created by Lindsey Boyer on 11/24/25.
//

import SwiftUI

struct RouteView: View {
    let route: RouteInfo
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userData: UserData

    // Helper for cleaning Firestore list-style strings (imported data was messy - maybe should've done it with python)
    private func cleanFirestoreList(_ text: String) -> String {
        var cleaned = text
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "'", with: "")
        
        cleaned = cleaned.replacingOccurrences(of: ",", with: " ")
        
        while cleaned.contains("  ") {
            cleaned = cleaned.replacingOccurrences(of: "  ", with: " ")
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        
                        // MARK: Route Header
                        HStack {
                            
                            // route name
                            Text(route.route_name)
                                .font(.custom("Manrope", size: 24).weight(.bold))
                            
                            Spacer()
                            
                            // route grade (YDS)
                            Text(route.nopm_YDS)
                                .font(.custom("Manrope", size: 20).weight(.semibold))
                        }
                        
                        // parent sector of route
                        Text(route.parent_sector)
                            .font(.custom("Manrope", size: 14))
                            .foregroundColor(.gray)
                        
                        // route type
                        HStack {
                            Text(route.type_string.capitalized)
                                .font(.custom("Manrope", size: 14).weight(.medium))
                            
                            Spacer()
                            
                            // route vote rating
                            Text("\(String(format: "%.1f", route.mean_rating)) stars (\(route.num_votes) votes)")
                                .font(.custom("Manrope", size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)
                    
                    // MARK: Image Placeholder
                    ZStack {
                        Rectangle()
                            .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .frame(height: 200)
                            .cornerRadius(16)
                        
                        // make it seem professional - figure out image imports from data??
                        Text("No image available")
                            .font(.custom("Manrope", size: 16).weight(.medium))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    }
                    .padding(.horizontal)
                    
                    // MARK: Route Description
                    if !route.description.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Description")
                                .font(.custom("Manrope", size: 20).weight(.bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(cleanFirestoreList(route.description))
                                .font(.custom("Manrope", size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: Route Location
                    if !route.location.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Location")
                                .font(.custom("Manrope", size: 20).weight(.bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(cleanFirestoreList(route.location))
                                .font(.custom("Manrope", size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: Tick & Bookmark Btns
                    let isTicked = userData.tickedClimbs.contains(where: { $0.id == route.id })
                    let isBookmarked = userData.bookmarkedClimbs.contains(where: { $0.id == route.id })

                    HStack(spacing: 32) {
                        Button(action: {
                            userData.toggleTick(for: route)
                        }) {
                            Text(isTicked ? "Ticked" : "Tick")
                                .font(.custom("Manrope", size: 16).weight(.bold))
                                .foregroundColor(.white)
                                .frame(width: 100, height: 44)
                                .background(
                                    isTicked ?
                                    // custom blue if ticked
                                    Color(red: 0.20, green: 0.40, blue: 0.60) :
                                    // else gray
                                    Color.gray
                                )
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            userData.toggleBookmark(for: route)
                        }) {
                            Text(isBookmarked ? "Bookmarked" : "Bookmark")
                                .font(.custom("Manrope", size: 16).weight(.bold))
                                .foregroundColor(.white)
                                .frame(width: 100, height: 44)
                                .background(
                                    isBookmarked ?
                                    // custom blue if bookmarked
                                    Color(red: 0.20, green: 0.40, blue: 0.60) :
                                    // else gray
                                    Color.gray
                                )
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top, 32)

                    Spacer()
                }
                .padding(.bottom, 20)
            }
            
            // Custom back buttom to dismiss route view sheet
            Button(action: { dismiss() }) {
                // user can also swipe down to dismiss the sheet
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemBackground).opacity(0.8))
                    .clipShape(Circle())
            }
            .padding(.leading, 16)
            .padding(.top, 8)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    // placeholder data to see preview
    NavigationStack {
        RouteView(route: RouteInfo(
            id: "1",
            route_name: "Petrified",
            type_string: "sport",
            parent_sector: "Steins Overlook",
            mean_rating: 2.67,
            nopm_YDS: "5.10d",
            state: "Oregon",
            description: "['P1. Techy corner moves to a steep finish.', 'P2. Very steep hand to fist crack.', '', 'Descent instructions.']",
            location: "['North facing side of Steins Overlook.']",
            num_votes: 3,
            safety: ""
        ))
        .environmentObject(UserData())
    }
}
