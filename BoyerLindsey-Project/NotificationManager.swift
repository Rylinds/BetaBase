//
//  NotificationManager.swift
//  BoyerLindsey-Project
//
//  Created by Lindsey Boyer on 12/8/25.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var notificationsEnabled: Bool = true
    private let notificationsEnabledKey = "notificationsEnabled"
    
    private init() {
        // load saved notification preference
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: notificationsEnabledKey)
    }
    
    // notif permission when launching the app
    func requestPermission() {
        // check status
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            // request if not determined (shouldn't be a concern since request is first-time upon launch)
            if settings.authorizationStatus == .notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .badge, .sound]
                ) { [weak self] granted, error in
                    if let _ = error {
                        // nothing happens here
                    }
                    
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.notificationsEnabled = granted
                        self.saveNotificationPreference()
                        
                        if granted {
                            DispatchQueue.main.async {
                                UIApplication.shared.registerForRemoteNotifications()
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.notificationsEnabled = settings.authorizationStatus == .authorized
                    self.saveNotificationPreference()
                }
            }
        }
    }
    
    // notif toggle logic
    func toggleNotifications(_ enable: Bool) {
        if enable {
            // enable notifs
            requestPermission()
        } else {
            // disable notifs
            self.notificationsEnabled = false
            self.saveNotificationPreference()
            disableNotifications()
        }
    }
    
    // turn off notifs
    func disableNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    // user gets congrats message for every 5 climbs
    func send5ClimbMilestone(climbCount: Int) {
        guard notificationsEnabled else { return }
        
        // Check if this is a milestone (multiple of 5)
        guard climbCount > 0 && climbCount % 5 == 0 else { return }
        
        // Check notification settings
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            
            // Create notification content
            let content = UNMutableNotificationContent()
            content.title = "Congrats on your sends!"
            content.body = "You've completed \(climbCount) climbs."
            content.sound = .default
            
            // Use appropriate delay for notification delivery
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 8.0, repeats: false)
            
            // Create unique identifier
            let identifier = "milestone_\(climbCount)_\(Int(Date().timeIntervalSince1970))"
            
            // Create request
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            // Add the notification request
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    // remember the user's preference
    private func saveNotificationPreference() {
        UserDefaults.standard.set(notificationsEnabled, forKey: notificationsEnabledKey)
    }
}
