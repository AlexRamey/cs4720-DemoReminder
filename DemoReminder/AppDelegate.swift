//
//  AppDelegate.swift
//  DemoReminder
//
//  Created by Spencer Gennari on 2/20/16.
//  Copyright © 2016 money-apps. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Register for notifications
        let notificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        let alertController = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .Alert)
        
        // Create notification actions
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Destructive) { (action) in
            let rootViewController = self.window?.rootViewController as! UINavigationController
            let tableViewController = rootViewController.viewControllers[0] as! TableViewController
            tableViewController.dismissReminder(notification.userInfo!["uuid"] as! String)
        }
        let postponeAction = UIAlertAction(title: "Postpone", style: .Cancel) { (action) in
            let rootViewController = self.window?.rootViewController as! UINavigationController
            let tableViewController = rootViewController.viewControllers[0] as! TableViewController
            tableViewController.postponeReminder(notification.userInfo!["uuid"] as! String)
        }
        
        // Add actions to AlertController
        alertController.addAction(postponeAction)
        alertController.addAction(dismissAction)
                
        // Get currently showing ViewController
        var currentViewController = self.window?.rootViewController
        
        // Move up through view controllers to get the topmost one
        while let next = currentViewController?.presentedViewController {
            currentViewController = next
        }
        
        // Show the alertController on the top ViewController
        currentViewController?.presentViewController(alertController, animated: true, completion: nil)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // Cancel local notificaitons when the app moves to background
        // Do this since the app does not persist data, so the notifications must be canceled
        // ---- TODO Possibly move this to another method
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        print(UIApplication.sharedApplication().scheduledLocalNotifications?.count)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if let rootViewController = self.window?.rootViewController as? UINavigationController{
            if let vc = rootViewController.viewControllers[0] as? TableViewController{
                vc.rescheduleAllNotifications()
            }
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

