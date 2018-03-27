//
//  AppDelegate.swift
//  Sync
//
//  Created by Hills, Dennis on 3/21/18.
//  Copyright © 2018 Hills, Dennis. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Register for push notifications
        registerForRemoteNotifications()
            
        // Push Notification
        // If your app wasn’t running and the user launches it by tapping the push notification, the push notification is passed to your app
        // Check if app was launched from notification
        // 1 - Check if this is a remote push notification by checking if UIApplicationLaunchOptionsKey.remoteNotification exists in launch
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            // 2 - If this IS a remote push notification, get the aps dictionary (which should be the exact aps payload you sent)
            let aps = notification["aps"] as! [String: AnyObject]
            let data = notification["data"] as! [String: AnyObject]
            
            // Play sound?
            if let mySoundFile : String = aps["sound"] as? String {
                playSound(fileName: mySoundFile)
            }
            
            print("(didFinishLaunchingWithOptions) aps: \(aps)\(data)")
        }
        
        // Always clear the push badges
        application.applicationIconBadgeNumber = 0;
        
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
    /// ### Since iOS 10, UNUserNotificationCenter is responsible for managing all notification-related activities inside the app ###
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
    
    // If app was running either in the foreground or background and a push notification is received
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // "customData":{"campaignId":"123456","keyName":"someValue"} OR (ESCAPED for SNS) \"customData\":{\"campaignId\":\"123456\",\"keyName\":\"someValue\"}
        // Looking for custom data "customData" key in the payload.
        if let data = userInfo["customData"] as? NSDictionary {
            print("Custom data: \(data)")
        }
        
        if let apsDict = userInfo["aps"] as? NSDictionary {
            print(apsDict)
        }
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        // Is silent push?
        if aps["content-available"] as? Int == 1 {
            print("Received Silent Push: \(aps)")
            
            // Make network call then call completionHandler (you have 30 seconds...GO!)
            
            completionHandler(UIBackgroundFetchResult.noData)
        }
        else
        {
            // Play sound?
            if let mySoundFile : String = aps["sound"] as? String {
                playSound(fileName: mySoundFile)
            }
            
            // Always clear badge
            application.applicationIconBadgeNumber = 0;
            
            print("(didReceiveRemoteNotification) Received a remote push notification: \(aps)")
        }
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
    
    func playSound(fileName: String) {
        var sound: SystemSoundID = 0
        if let soundURL = Bundle.main.url(forAuxiliaryExecutable: fileName) {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &sound)
            AudioServicesPlaySystemSound(sound)
        }
    }
}

