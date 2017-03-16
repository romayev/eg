//
//  AppDelegate.swift
//  grafixpool
//
//  Created by Alex Romayev on 2/24/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    var window: UIWindow?
    var selectedTabIdx = 0
    var tabBarController = TabBarController()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let navbarTintColor = UIColor.Siemens.blue3
        let whiteColor = UIColor.white

        window?.tintColor = navbarTintColor

        let navigationBar = UINavigationBar.appearance()
        navigationBar.tintColor = whiteColor
        navigationBar.barTintColor = navbarTintColor
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        let font = UIFont(name: "Arial", size: 18.0) ?? UIFont.systemFont(ofSize: 18.0)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: whiteColor, NSFontAttributeName: font]

        tabBarController = window?.rootViewController as! TabBarController;
        tabBarController.delegate = self

        let center = UNUserNotificationCenter.current()
        center.delegate = tabBarController

        let changeAction = UNNotificationAction(identifier: BookingNotification.update.rawValue, title: NSLocalizedString("edit-booking", comment: ""), options: [.foreground])
        let cancelAction = UNNotificationAction(identifier: BookingNotification.cancel.rawValue, title: NSLocalizedString("cancel-booking", comment: ""), options: .foreground)
        let category = UNNotificationCategory(identifier: "booking-actions", actions: [changeAction, cancelAction], intentIdentifiers: [], options: [.customDismissAction])
        center.setNotificationCategories([category])

        return true
    }

    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }

    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        selectedTabIdx = tabBarController.selectedIndex;
        return true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if (tabBarController.selectedIndex != selectedTabIdx) {
            return;
        }

        if (tabBarController.selectedViewController?.isKind(of: UISplitViewController.self))! {
            let splitView = viewController as! UISplitViewController
            let viewControllers = splitView.viewControllers
            for navControllerInSplit in viewControllers {
                if let n: UINavigationController = navControllerInSplit as? UINavigationController {
                    n.popToRootViewController(animated: true)
                }
            }
        }
    }
}



