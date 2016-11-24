//
//  ISHomeSplitViewController.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/15/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISHomeSplitViewController.h"

@interface ISHomeSplitViewController () <UISplitViewControllerDelegate>
@end

@implementation ISHomeSplitViewController


- (void) awakeFromNib {
    [super awakeFromNib];
    [self setDelegate: self];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark -
#pragma mark UISplitViewControllerDelegate

- (BOOL) splitViewController: (UISplitViewController *) splitViewController collapseSecondaryViewController: (UIViewController *) secondaryViewController ontoPrimaryViewController: (UIViewController *) primaryViewController {
    // Show tools table on the iPhone
    if ([self isPhone]) {
        return YES;
    }

    return NO;
}

- (BOOL) isPhone {
    const UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    return idiom == UIUserInterfaceIdiomPhone;
}

@end
