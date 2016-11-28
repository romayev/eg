//
//  ISIndexViewController.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/15/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISIndexViewController.h"
#import "ISSearchViewController.h"


#define kNumberOfTools  11

@interface ISIndexViewController () <UITableViewDelegate, UITableViewDataSource, ISSearchViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end


@implementation ISIndexViewController {
    NSInteger _selected;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"ingredion", nil);
}
- (void) viewDidAppear: (BOOL) animated {
    [super viewDidAppear: animated];

    if ([self isPhone]) {
        NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
        if (indexPath) {
            [_tableView deselectRowAtIndexPath: indexPath animated: YES];
        }
    }
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender {
    [super prepareForSegue: segue sender: sender];

    NSString *identifier = [segue identifier];
    if ([identifier isEqualToString: @"confectionery"]) {
        ISSearchViewController *c = [segue destinationViewController];
        [c setDelegate: self];
    }
}


#pragma mark -
#pragma mark UITableViewDelegate and DataSource

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
    return kNumberOfTools;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    UILabel *label = (UILabel *) [cell viewWithTag: 100];
    NSString *key = [NSString stringWithFormat: @"%@%zi", @"index.title.", indexPath.row];
    label.text = NSLocalizedString(key, nil);
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    // Crashlytics: Pushing the same view controller instance more than once is not supported
    if (self.navigationController.topViewController != self) return;

    const NSInteger tag = [indexPath row];
    [self showToolViewController: tag animated: YES];
}

- (void) showToolViewController: (NSInteger) tag animated: (BOOL) animated {
    NSString *segue = nil;
    switch (tag) {
        default:
        case 0:
            segue = @"yogurt";
            break;
        case 1:
            segue = @"cheese";
            break;
        case 2:
            segue = @"creamy";
            break;
        case 3:
            segue = @"carrageenan";
            break;
        case 4:
            segue = @"beverages";
            break;
        case 5:
            segue = @"meat";
            break;
        case 6:
            segue = @"batters";
            break;
        case 7:
            segue = @"hydrocolloids";
            break;
        case 8:
            segue = @"confectionery";
            break;
        case 9:
            segue = @"tomato";
            break;
        case 10:
            segue = @"thickener";
            break;
    }

    // FIXME: Remove
    if (tag != 8) {
        segue = @"confectionery";
    }

    if (segue) {
        _selected = tag;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow: _selected inSection: 0];
        if (![indexPath isEqual: [_tableView indexPathForSelectedRow]]) {
            [_tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition: UITableViewScrollPositionNone];
        }
        [self performSegueWithIdentifier: segue sender: nil];
    }
}


#pragma mark -
#pragma mark ISSearchViewControllerDelegate

- (NSInteger) productIndex {
    return [[_tableView indexPathForSelectedRow] row];
}

@end
