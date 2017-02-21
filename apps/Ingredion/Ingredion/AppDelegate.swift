//
//  AppDelegate.swift
//  Ingredion
//
//  Created by Alex Romayev on 2/9/17.
//  Copyright © 2017 Executive Graphic. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var selectedTabIdx = 0
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let greenColor = UIColor(red: 0.42, green: 0.70, blue: 0.24, alpha: 1.0)
        let orangeColor = UIColor(red: 0.96, green: 0.48, blue: 0.13, alpha: 1.0)
        let whiteColor = UIColor.white

        window?.tintColor = greenColor
        let tabBar = UITabBar.appearance()
        tabBar.tintColor = whiteColor
        tabBar.barTintColor = UIColor.black

        let navigationBar = UINavigationBar.appearance()
        navigationBar.tintColor = whiteColor
        navigationBar.barTintColor = greenColor

        UIToolbar.appearance().tintColor = orangeColor
        UIToolbar.appearance().tintColor = whiteColor

        let font = UIFont(name: "GillSans", size: 22.0) ?? UIFont.systemFont(ofSize: 22.0)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: whiteColor, NSFontAttributeName: font]

        let tabBarController: UITabBarController = window?.rootViewController as! UITabBarController;
        tabBarController.delegate = self

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

