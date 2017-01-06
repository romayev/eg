//
//  ISExpertsViewController.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 1/6/17.
//  Copyright © 2017 Alex Romayev. All rights reserved.
//

#import "ISExpertsViewController.h"

@interface ISExpertsViewController ()
@property (strong, nonatomic) IBOutlet UILabel *noInfoLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@end


@implementation ISExpertsViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"experts", nil);
    ISProductType type = [_delegate productType];
    if (type == ISBeverages) {
        [_noInfoLabel setHidden: NO];
        [_containerView setHidden: YES];
    } else {
        [_noInfoLabel setHidden: YES];
        [_containerView setHidden: NO];
    }
}

@end
