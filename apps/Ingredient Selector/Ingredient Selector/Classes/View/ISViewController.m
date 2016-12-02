//
//  ISViewController.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/15/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISViewController.h"


@interface ISViewController ()

@end

@implementation ISViewController

static BOOL __isPad;
static BOOL __isPhone5;
static BOOL __isPhone6;
static BOOL __isPhone6Plus;

#pragma mark -
#pragma mark Setup / Tear Down

+ (void) initialize {
    if (self == [ISViewController class]) {
        const UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
        __isPad = (idiom == UIUserInterfaceIdiomPad);
        if (idiom == UIUserInterfaceIdiomPhone) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            if (result.height == 480) {
                // iPhone 4s
            } if (result.height == 568) {
                __isPhone5 = YES;
            } else if (result.height == 667) {
                __isPhone6 = YES;
            } else if (result.height == 736) {
                __isPhone6Plus = YES;
            }
        }
    }
}

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (BOOL) isPhone {
    return !__isPad;
}


#pragma mark -
#pragma mark Done / Dismiss

- (void) done: (id) sender {
    [self dismissViewControllerAnimated: YES completion: NULL];
}

- (IBAction) dismiss: (UIStoryboardSegue *) segue {
    NSLog(@"Dismiss from %@", segue.sourceViewController);
    // nothing
    if (__isPad) {
        [self dismissViewControllerAnimated: YES completion: NULL];
    }
}

@end
