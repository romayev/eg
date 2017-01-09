//
//  ISMoreViewController.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/27/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISMoreViewController.h"

@interface ISMoreViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleAboutLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleContactLabel;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactTitleLabel;
@property (strong, nonatomic) IBOutlet UITextView *contactTextView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contactTextViewHeightConstraint;
@end

@implementation ISMoreViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    if ([[UIScreen mainScreen] bounds].size.height <= 568.0) {
        [_backgroundImageView setHidden: YES];
    }
    self.navigationItem.title = NSLocalizedString(@"ingredion", nil);
    _titleAboutLabel.text = NSLocalizedString(@"more.title-about", nil);
    _titleContactLabel.text = NSLocalizedString(@"more.title-contact", nil);
    _descLabel.text = NSLocalizedString(@"more.desc", nil);
    _contactNameLabel.text = NSLocalizedString(@"more.contact.name", nil);
    _contactTitleLabel.text = NSLocalizedString(@"more.contact.title", nil);
    _contactTextView.text = NSLocalizedString(@"more.contact.email-phone", nil);
    CGSize size = [_contactTextView sizeThatFits: CGSizeMake(_contactTextView.frame.size.width, MAXFLOAT)];
    _contactTextViewHeightConstraint.constant = size.height;
}

- (void) willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (newCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact && newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        [_backgroundImageView setAlpha: 0.0];
    } else {
        [_backgroundImageView setAlpha: 1.0];
    }
}

@end
