//
//  FullTickListView.swift
//  BoyerLindsey-Project
//
//  Created by Lindsey Boyer on 11/24/25.
//

// tick list is structured like search view except it's a sheet
import SwiftUI

struct FullTickListView: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredTicks: [RouteInfo] {
        if searchText.isEmpty {
            return userData.tickedClimbs
        } else {
            return userData.tickedClimbs.filter { $0.route_name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                
                // custom back button
                Button(action: { dismiss() }) {
                    // or user can swipe down to dismiss list view sheet
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemBackground).opacity(0.8))
                        .clipShape(Circle())
                        .shadow(radius: 1)
                }
                .padding(.leading)
                .padding(.top)
                
                // search bar
                TextField("Search routes…", text: $searchText)
                    .padding(12)
                    .background(Color(.systemGray5))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .onSubmit {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                
                // tick list
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(filteredTicks) { route in
                            NavigationLink(value: route) {
                                RouteCard(route: route)
                            }
                        }
                        
                        if filteredTicks.isEmpty {
                            Text("No matching ticks.")
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .navigationDestination(for: RouteInfo.self) { route in
                    RouteView(route: route)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    FullTickListView()
        .environmentObject(UserData())
}
