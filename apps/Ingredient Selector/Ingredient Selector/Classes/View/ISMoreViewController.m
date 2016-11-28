//
//  ISMoreViewController.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/27/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISMoreViewController.h"

@interface ISMoreViewController ()
@property (strong, nonatomic) IBOutlet UILabel *aboutLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;
@end

@implementation ISMoreViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"ingredion", nil);
    _aboutLabel.text = NSLocalizedString(@"company.meet-company", nil);
    _titleLabel.text = NSLocalizedString(@"company.locations-title", nil);
    _descLabel.text = NSLocalizedString(@"company.locations-desc", nil);
}

@end
