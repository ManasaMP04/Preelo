//
//  AppDelegate.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import ObjectMapper
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import Security

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        
        setInitialVC()
        
        return true
    }
    
    fileprivate func setInitialVC() {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let defaults = UserDefaults.standard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let status = defaults.value(forKey: "isLoggedIn") as? Bool, status {
            
            StaticContentFile.callApiToRegisterDevice()
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "tabVC")
            let nav = UINavigationController.init(rootViewController: initialViewController)
            self.window?.rootViewController = nav
        } else {
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "navigation")
            self.window?.rootViewController = initialViewController
        }
        
        self.window?.makeKeyAndVisible()
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        MessageVC.sharedInstance.handleRemoteNotification()
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: "deviceID")
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        MessageVC.sharedInstance.closeConnection()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        let defaults = UserDefaults.standard
        if let status = defaults.value(forKey: "isLoggedIn") as? Bool, status,
             Reachability.forInternetConnection().isReachable() {
            
            MessageVC.sharedInstance.callChannelAPI()
            StaticContentFile.isDoctorLogIn() ? MessageVC.sharedInstance.callAPIToGetAuthRequest() : MessageVC.sharedInstance.callAPIToGetPatientAuthRequest()
        }
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        let defaults = UserDefaults.standard
        if let status = defaults.value(forKey: "isLoggedIn") as? Bool, status {
        
            MessageVC.sharedInstance.establishConnection()
        }
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

