//
//  UserData.swift
//  BoyerLindsey-Project
//
//  Created by Lindsey Boyer on 11/24/25.
//

// contains user auth, ticked climbs, bookmarked climbs, light/dark preferences
import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class UserData: ObservableObject {
    @Published var tickedClimbs: [RouteInfo] = []
    @Published var bookmarkedClimbs: [RouteInfo] = []
    @Published var userId: String?
    @Published var isDarkMode: Bool = UserDefaults.standard.bool(forKey: "isDarkMode") {
            didSet {
                UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            }
        }
    @Published var totalTicks: Int = 0

    private let db = Firestore.firestore()

    init() {
        // listen for auth changes and load ticks
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            self.userId = user?.uid

            // load all user data
            if let uid = user?.uid {
                self.loadTicks(for: uid)
                self.loadBookmarks(for: uid)
                self.loadDarkModePreference(for: uid)
                NotificationManager.shared.requestPermission()
            // if new user, data is empty and default is light mode
            } else {
                self.tickedClimbs = []
                self.bookmarkedClimbs = []
                self.isDarkMode = false
                NotificationManager.shared.requestPermission()
            }
        }
    }
    
    // MARK: Dark Mode Data
    func updateDarkModePreference(_ isDark: Bool) {
        self.isDarkMode = isDark
         
        guard let uid = userId else { return }
         
        let docRef = db.collection("users")
            .document(uid)
            .collection("preferences")
            .document("appearance")
         
        let data: [String: Any] = [
            "isDarkMode": isDark,
            "lastUpdated": FieldValue.serverTimestamp()
        ]
         
        docRef.setData(data) { error in
            if let error = error {
                print("Error saving dark mode preference: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Query Dark Mode Preference
    private func loadDarkModePreference(for uid: String) {
        let docRef = db.collection("users")
            .document(uid)
            .collection("preferences")
            .document("appearance")
            
        docRef.getDocument { snapshot, error in
            if let error = error {
                print("Error loading dark mode preference: \(error.localizedDescription)")
                return
            }
                
            if let data = snapshot?.data(),
                let isDarkMode = data["isDarkMode"] as? Bool {
                DispatchQueue.main.async {
                    self.isDarkMode = isDarkMode
                }
            }
        }
    }

    // MARK: Toggle Tick
    func toggleTick(for route: RouteInfo) {
        // remove tick if btn is not active (gray)
        if tickedClimbs.contains(where: { $0.id == route.id }) {
            removeTick(route)
        // else, add tick to tick list when btn is active (blue)
        } else {
            addTick(route)
        }
    }
    
    // MARK: Toggle bookmark
    func toggleBookmark(for route: RouteInfo) {
        // remove bookmark if btn is not active (gray)
        if bookmarkedClimbs.contains(where: { $0.id == route.id }) {
            removeBookmark(route)
        // else, add bookmark to bokmark list when btn is active (gray)
        } else {
            addBookmark(route)
        }
    }

    // MARK: Add tick to Firestore
    private func addTick(_ route: RouteInfo) {
        guard let uid = userId else { return }

        let docRef = db.collection("users")
            .document(uid)
            .collection("ticks")
            .document(route.id)

        // route data structure (follows structure from imported data)
        let data: [String: Any] = [
            "route_id": route.id,
            "route_name": route.route_name,
            "grade": route.nopm_YDS,
            "type_string": route.type_string,
            "parent_sector": route.parent_sector,
            "state": route.state,
            "mean_rating": route.mean_rating,
            "num_votes": route.num_votes,
            "description": route.description,
            "location": route.location,
            "timestamp": FieldValue.serverTimestamp()
        ]

        docRef.setData(data) { error in
            if let error = error {
                print("Error adding tick: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.tickedClimbs.insert(route, at: 0)
                self.totalTicks = self.tickedClimbs.count
                
                // notif for multiples of 5 climbs
                if self.totalTicks % 5 == 0 {
                    NotificationManager.shared.send5ClimbMilestone(
                        climbCount: self.totalTicks
                    )
                }
            }
        }
    }
    
    // MARK: Add bookmark to Firestore
    private func addBookmark(_ route: RouteInfo) {
        guard let uid = userId else { return }

        let docRef = db.collection("users")
            .document(uid)
            .collection("bookmarks")
            .document(route.id)

        // same structure as a typical route (info behaves the same)
        let data: [String: Any] = [
            "route_id": route.id,
            "route_name": route.route_name,
            "grade": route.nopm_YDS,
            "type_string": route.type_string,
            "parent_sector": route.parent_sector,
            "state": route.state,
            "mean_rating": route.mean_rating,
            "num_votes": route.num_votes,
            "description": route.description,
            "location": route.location,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        docRef.setData(data) { error in
            if let error = error {
                print("Error adding bookmark: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.bookmarkedClimbs.insert(route, at: 0)
            }
        }
    }

    // MARK: Remove tick from Firestore
    private func removeTick(_ route: RouteInfo) {
        guard let uid = userId else { return }

        let docRef = db.collection("users")
            .document(uid)
            .collection("ticks")
            .document(route.id)

        docRef.delete { error in
            if let error = error {
                print("Error removing tick: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.tickedClimbs.removeAll { $0.id == route.id }
                self.totalTicks = self.tickedClimbs.count
            }
        }
    }
    
    // MARK: Remove bookmark from Firestore
    private func removeBookmark(_ route: RouteInfo) {
        guard let uid = userId else { return }

        let docRef = db.collection("users")
            .document(uid)
            .collection("bookmarks")
            .document(route.id)

        docRef.delete { error in
            if let error = error {
                print("Error removing bookmark: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.bookmarkedClimbs.removeAll { $0.id == route.id }
            }
        }
    }

    // MARK: Load ticks on login
    private func loadTicks(for uid: String) {
        db.collection("users")
            .document(uid)
            .collection("ticks")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in

                if let error = error {
                    print("Error loading ticks: \(error.localizedDescription)")
                    return
                }

                var loaded: [RouteInfo] = []

                for doc in snapshot?.documents ?? [] {
                    let data = doc.data()

                    let route = RouteInfo(
                        id: data["route_id"] as? String ?? doc.documentID,
                        route_name: data["route_name"] as? String ?? "",
                        type_string: data["type_string"] as? String ?? "",
                        parent_sector: data["parent_sector"] as? String ?? "",
                        mean_rating: data["mean_rating"] as? Double ?? 0.0,
                        nopm_YDS: data["grade"] as? String ?? "",
                        state: data["state"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        location: data["location"] as? String ?? "",
                        num_votes: data["num_votes"] as? Int ?? 0,
                        safety: ""
                    )

                    loaded.append(route)
                }

                DispatchQueue.main.async {
                    self.tickedClimbs = loaded
                    self.totalTicks = loaded.count
                }
            }
    }
    
    // MARK: Load bookmarks on login
    private func loadBookmarks(for uid: String) {
        db.collection("users")
            .document(uid)
            .collection("bookmarks")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in

                if let error = error {
                    print("Error loading bookmarks: \(error.localizedDescription)")
                    return
                }

                var loaded: [RouteInfo] = []

                for doc in snapshot?.documents ?? [] {
                    let data = doc.data()
                    
                    let route = RouteInfo(
                        id: data["route_id"] as? String ?? doc.documentID,
                        route_name: data["route_name"] as? String ?? "",
                        type_string: data["type_string"] as? String ?? "",
                        parent_sector: data["parent_sector"] as? String ?? "",
                        mean_rating: data["mean_rating"] as? Double ?? 0.0,
                        nopm_YDS: data["grade"] as? String ?? "",
                        state: data["state"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        location: data["location"] as? String ?? "",
                        num_votes: data["num_votes"] as? Int ?? 0,
                        safety: ""
                    )

                    loaded.append(route)
                }

                DispatchQueue.main.async {
                    self.bookmarkedClimbs = loaded
                }
            }
    }
    
    // MARK: Sign out User
    func signOut() {
            do {
                try Auth.auth().signOut()

                DispatchQueue.main.async {
                    self.userId = nil
                    self.tickedClimbs = []
                    self.bookmarkedClimbs = []
                    self.isDarkMode = false
                }
                
                // force immediate window style update -> content view is light mode for all users
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let window = windowScene.windows.first {
                    window.overrideUserInterfaceStyle = .light
                }

            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
    
    // MARK: Delete Account
    @MainActor
    func deleteAccount() async throws {
        guard let uid = userId else { return }

        // delete all ticks
        let ticks = try await db.collection("users")
            .document(uid)
            .collection("ticks")
            .getDocuments()

        for doc in ticks.documents {
            try await doc.reference.delete()
        }
        
        // delete all bookmarks
        let bookmarks = try await db.collection("users")
            .document(uid)
            .collection("bookmarks")
            .getDocuments()
        
        for doc in bookmarks.documents {
            try await doc.reference.delete()
        }
        
        // delete all preferences (including dark mode)
        let preferences = try await db.collection("users")
            .document(uid)
            .collection("preferences")
            .getDocuments()

        for doc in preferences.documents {
            try await doc.reference.delete()
        }

        // delete the user document
        try await db.collection("users")
            .document(uid)
            .delete()

        // delete Firebase Auth account
        if let user = Auth.auth().currentUser {
            try await user.delete()
        }

        // clear local state for that user
        self.userId = nil
        self.tickedClimbs = []
        self.bookmarkedClimbs = []
        self.isDarkMode = false
    }
}
