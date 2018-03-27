//
//  AppDelegate.swift
//  Sync
//
//  Created by Hills, Dennis on 3/21/18.
//  Copyright © 2018 Hills, Dennis. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Register for push notifications
        registerForRemoteNotifications()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
       
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
       
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    /// Remote Push Notifications - Request permission to send alerts, sound, and badge push notitifications
    /// Since iOS 10, UNUserNotificationCenter is responsible for managing all notification-related activities inside the app
    /// This function should be called everytime the app launches
    func registerForRemoteNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            if granted {
                print("Permission granted: \(granted)")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("User has disabled push push notifications")
                
                //guard granted else { return } //ADD BACK IN
                self.checkPushNotificationSettings() // completionHandler:
            }
        }
    }
    
    /// Push Notifications - Check permissions user granted permissions for Remote Push Notifications
    /// Here you verify the authorizationStatus is .authorized, which means the user has granted notification permissions. If so, call registerForRemoteNotifications()
    func checkPushNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        print("Received a remote push notification: \(aps)")
    }
    
    /// Push Notifications - Callback for when device has SUCCESSFULLY registered with Apple for Push Notifications
    /// Converts the Data deviceToken to a string
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Registered Successfully with Device Push Token: \(token)")
        
        // Pass token to Amazon Pinpoint or SNS
    }
    
    /// Push Notifications - Callback if the device FAILED to register for remote push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for push notifications: \(error)")
    }
}

