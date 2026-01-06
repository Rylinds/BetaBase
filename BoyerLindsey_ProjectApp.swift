//
//  BoyerLindsey_ProjectApp.swift
//  BoyerLindsey-Project
//
//  Created by Lindsey Boyer on 11/23/25.
//

import SwiftUI
import FirebaseCore
import Firebase

// AppDelegate for Firebase initialization
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct BoyerLindsey_ProjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // make sure navigation is flow
    @StateObject private var navigationState = NavigationState()
    // make sure user data persists across all screens
    @StateObject private var userData = UserData()
    @StateObject private var notificationManager = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationState)
                .environmentObject(userData)
                .environmentObject(NotificationManager.shared)
                .onAppear {
                    notificationManager.requestPermission()
                }
        }
    }
}
