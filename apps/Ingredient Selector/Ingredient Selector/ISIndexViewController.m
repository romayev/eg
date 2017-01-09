//
//  ISIndexViewController.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/15/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISIndexViewController.h"
#import "ISSearchViewController.h"


@interface ISIndexViewController () <UITableViewDelegate, UITableViewDataSource, ISSearchViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end


@implementation ISIndexViewController {
    ISProductType _productType;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    _productType = ISBeverages;
    self.navigationItem.title = NSLocalizedString(@"index.title", nil);
    _tableView.tableFooterView = [[UIView alloc] initWithFrame: CGRectZero];

    if (![self isPhone]) {
        [self showToolViewController: ISBeverages animated: YES];
    }
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
    if ([identifier isEqualToString: @"search"]) {
        UINavigationController *n = [segue destinationViewController];
        ISSearchViewController *c = (ISSearchViewController *) [n topViewController];
        [c setDelegate: self];
    }
}


#pragma mark -
#pragma mark UITableViewDelegate and DataSource

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
    return ISProductTypeCount;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    UILabel *label = (UILabel *) [cell viewWithTag: 100];
    NSString *key = [NSString stringWithFormat: @"%@%zi", @"index.title.", indexPath.row];
    label.text = NSLocalizedString(key, nil);

    if (indexPath.row != ISBeverages && indexPath.row != ISConfectionery) {
        [cell setUserInteractionEnabled: NO];
        [label setAlpha: 0.5];
    }
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    // Crashlytics: Pushing the same view controller instance more than once is not supported
    if (self.navigationController.topViewController != self) return;

    const NSInteger tag = [indexPath row];
    [self showToolViewController: tag animated: YES];
}

- (void) showToolViewController: (NSInteger) tag animated: (BOOL) animated {
    _productType = (ISProductType) tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow: tag inSection: 0];
    if (![indexPath isEqual: [_tableView indexPathForSelectedRow]]) {
        [_tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition: UITableViewScrollPositionNone];
    }
    if (_productType != ISBeverages && _productType != ISConfectionery) {
        _productType = ISConfectionery;
    }
    [self performSegueWithIdentifier: @"search" sender: nil];
}


#pragma mark -
#pragma mark ISSearchViewControllerDelegate

- (ISProductType) productType {
    return _productType;
}

@end
