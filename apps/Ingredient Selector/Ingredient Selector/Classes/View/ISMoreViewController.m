//
//  ISMoreViewController.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/27/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISMoreViewController.h"

@interface ISMoreViewController ()
@property (strong, nonatomic) IBOutlet UILabel *titleAboutLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleContactLabel;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactTitleLabel;
@property (strong, nonatomic) IBOutlet UITextView *contactTextView;
@end

@implementation ISMoreViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"ingredion", nil);
    _titleAboutLabel.text = NSLocalizedString(@"more.title-about", nil);
    _titleContactLabel.text = NSLocalizedString(@"more.title-contact", nil);
    _descLabel.text = NSLocalizedString(@"more.desc", nil);
    _contactNameLabel.text = NSLocalizedString(@"more.contact.name", nil);
    _contactTitleLabel.text = NSLocalizedString(@"more.contact.title", nil);
    _contactTextView.text = NSLocalizedString(@"more.contact.email-phone", nil);
}

@end
