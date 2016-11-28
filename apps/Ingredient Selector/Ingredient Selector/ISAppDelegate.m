//
//  ISAppDelegate.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/14/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISAppDelegate.h"


@interface ISAppDelegate ()

@end

@implementation ISAppDelegate


- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions {
    // Setup appearance
    UIColor *greenColor = [UIColor colorWithRed: 0.42 green: 0.70 blue: 0.24 alpha: 1.0];
    //UIColor *darkGreyColor = [UIColor colorWithRed: 0.20 green: 0.20 blue: 0.20 alpha: 1.0];
    [_window setTintColor: greenColor];
    UITabBar *tabBar = [UITabBar appearance];
    [tabBar setTintColor: [UIColor whiteColor]];
    [tabBar setBarTintColor: [UIColor blackColor]];
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar setTintColor: [UIColor whiteColor]];
    [navigationBar setBarTintColor: greenColor];

    //[navigationBar setTranslucent: NO];
    [navigationBar setTitleTextAttributes: @{
                                             NSForegroundColorAttributeName: [UIColor whiteColor],
                                             NSFontAttributeName:            [UIFont fontWithName: @"MiloOT-Black" size: 22.0]
                                             }];

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
    [self saveContext];
}


#pragma mark -
#pragma mark Restoration

- (BOOL) application: (UIApplication *) application shouldSaveApplicationState: (NSCoder *) coder {
    return YES;
}

- (BOOL) application: (UIApplication *) application shouldRestoreApplicationState: (NSCoder *) coder {
    return YES;
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Ingredient_Selector"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
