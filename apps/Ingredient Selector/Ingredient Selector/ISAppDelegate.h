//
//  ISAppDelegate.h
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/14/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ISAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

