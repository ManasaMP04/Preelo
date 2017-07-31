//
//  AppDelegate.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        
        application.applicationIconBadgeNumber = 0
        
        setInitialVC()
        
        return true
    }
    
    fileprivate func setInitialVC() {
    
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let defaults = UserDefaults.standard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let status = defaults.value(forKey: "isLoggedIn") as? Bool, status {
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "tabVC")
            let nav = UINavigationController.init(rootViewController: initialViewController)
            self.window?.rootViewController = nav
        } else {
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "navigation")
            self.window?.rootViewController = initialViewController
        }
        
        self.window?.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        MessageVC.sharedInstance.closeConnection()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        MessageVC.sharedInstance.establishConnection()
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

