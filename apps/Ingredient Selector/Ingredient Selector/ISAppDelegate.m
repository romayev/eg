//
//  ISAppDelegate.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/14/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISAppDelegate.h"


@interface ISAppDelegate () <UITabBarControllerDelegate>
@end


@implementation ISAppDelegate  {
    NSUInteger      _selectedTabIdx;
}


- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions {
    // Setup appearance
    UIColor *greenColor = [UIColor colorWithRed: 0.42 green: 0.70 blue: 0.24 alpha: 1.0];
//    UIColor *pinkColor = [UIColor colorWithRed: 0.71 green: 0.12 blue: 0.46 alpha: 1.0];
//    UIColor *darkGrayColor = [UIColor colorWithRed: 0.33 green: 0.33 blue: 0.33 alpha: 1.0];
//    UIColor *blueColor = [UIColor colorWithRed: 0.00 green: 0.42 blue: 0.44 alpha: 1.0];
    UIColor *orangeColor = [UIColor colorWithRed:0.96 green:0.48 blue:0.13 alpha:1.0];

    [_window setTintColor: greenColor];
    UITabBar *tabBar = [UITabBar appearance];
    [tabBar setTintColor: [UIColor whiteColor]];
    [tabBar setBarTintColor: [UIColor blackColor]];
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar setTintColor: [UIColor whiteColor]];
    [navigationBar setBarTintColor: greenColor];

    [[UIToolbar appearance] setBarTintColor: orangeColor];
    [[UIToolbar appearance] setTintColor: [UIColor whiteColor]];
    //[navigationBar setTranslucent: NO];
    [navigationBar setTitleTextAttributes: @{
                                             NSForegroundColorAttributeName: [UIColor whiteColor],
                                             NSFontAttributeName:            [UIFont fontWithName: @"GillSans" size: 22.0]
                                             }];

    UITabBarController *tabBarController = (UITabBarController *) self.window.rootViewController;
    [tabBarController setDelegate: self];

    return YES;
}

- (void) applicationWillResignActive: (UIApplication *) application {
}


- (void) applicationDidEnterBackground: (UIApplication *) application {
}


- (void) applicationWillEnterForeground: (UIApplication *) application {
}


- (void) applicationDidBecomeActive: (UIApplication *) application {
}

- (void) applicationWillTerminate: (UIApplication *) application {
}


#pragma mark -
#pragma mark Restoration

- (BOOL) application: (UIApplication *) application shouldSaveApplicationState: (NSCoder *) coder {
    return YES;
}

- (BOOL) application: (UIApplication *) application shouldRestoreApplicationState: (NSCoder *) coder {
    return YES;
}


#pragma mark -
#pragma mark UITabBarControllerDelegate

- (BOOL) tabBarController: (UITabBarController *) tabBarController shouldSelectViewController: (UIViewController *) viewController {
    _selectedTabIdx = tabBarController.selectedIndex;
    return YES;
}

- (void) tabBarController: (UITabBarController *) tabBarController didSelectViewController: (UIViewController *) viewController {
    if (tabBarController.selectedIndex != _selectedTabIdx) return;

    if ([tabBarController.selectedViewController isKindOfClass: [UISplitViewController class]]) {
        UISplitViewController *splitView = (UISplitViewController *) viewController;
        for (UIViewController *navControllerInSplit in splitView.viewControllers) {
            if ([navControllerInSplit isKindOfClass: [UINavigationController class]]) {
                [(UINavigationController*) navControllerInSplit popToRootViewControllerAnimated: YES];
            }
        }
    }
}

@end
