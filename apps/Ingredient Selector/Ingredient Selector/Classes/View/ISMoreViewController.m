//
//  ISMoreViewController.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/27/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISMoreViewController.h"

@interface ISMoreViewController ()
@property (strong, nonatomic) IBOutlet UILabel *moreTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *moreDescLabel;
@property (strong, nonatomic) IBOutlet UILabel *moreQuestionsTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *moreQuestionsDescLabel;
@property (strong, nonatomic) IBOutlet UITextView *contactTextView;
@end

@implementation ISMoreViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"ingredion", nil);
//    _moreTitleLabel.text = NSLocalizedString(@"more.title", nil);
    _moreDescLabel.text = NSLocalizedString(@"more.desc", nil);
//    _moreQuestionsTitleLabel.text = NSLocalizedString(@"more.questions.title", nil);
//    _moreQuestionsDescLabel.text = NSLocalizedString(@"more.questions.desc", nil);
//    _contactTextView.text = NSLocalizedString(@"more.contact", nil);
}

@end
