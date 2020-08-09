//
//  AppDelegate.swift
//  Alert Service Test App
//
//  Created by Sarah Young on 8/4/20.
//  Copyright © 2020 Sarah Young. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerForPushNotifications()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        registerDeviceRequest(token: token)
    }

    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Failed to register: \(error)")
    }
    
    func application(
      _ application: UIApplication,
      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
      fetchCompletionHandler completionHandler:
      @escaping (UIBackgroundFetchResult) -> Void
    ) {
        
      guard var aps = userInfo["aps"] as? [String: AnyObject] else {
        completionHandler(.failed)
        return
      }
        guard let notificationId = aps.removeValue(forKey: "notificationId") as? String else {
          completionHandler(.failed)
          return
        }
        print("Received Notification: \(notificationId)")
        acknowledgeNotificationRequest(notificationId: notificationId)

    }
    
    func registerForPushNotifications() {
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) {
          [weak self] granted, error in
          print("Permission granted: \(granted)")
            self?.getNotificationSettings()
      }
    }

    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
    
    func acknowledgeNotificationRequest(notificationId: String) {
        let url = "ackNotification"
        let parameters = ["notificationId": notificationId, "notificationName": "Demo Test Notification"]
        MakeHttpRequest.sharedInstance.postRequest(api: url, parameters: parameters)
        print("Acknowledgement sent for notification with ID: \(notificationId)")
    }
    
    func registerDeviceRequest(token: String) {
        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else { return }
            let url = "registerDevice"
            let parameters = ["deviceId":uuid, "deviceToken":token]
            MakeHttpRequest.sharedInstance.postRequest(api: url, parameters: parameters)
        print("UUID: \(uuid)")
        print("Device Token: \(token)")
    }
}
