//
//  ISProductsViewController.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/25/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISProductsViewController.h"
#import "ISProductViewController.h"
#import "ISProduct.h"


@interface ISProductsCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@end


@interface ISProductsViewController () <UITableViewDelegate, UITableViewDataSource, ISProductsViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, readonly) NSArray *products;
@end


@implementation ISProductsViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"products", nil);
    _products = [_delegate products];
}

- (void) viewDidAppear: (BOOL) animated {
    [super viewDidAppear: animated];
    [_tableView deselectRowAtIndexPath: [_tableView indexPathForSelectedRow] animated: YES];
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender {
    [super prepareForSegue: segue sender: sender];

    NSString *identifier = [segue identifier];
    if ([identifier isEqualToString: @"product"]) {
        ISProductViewController *c = [segue destinationViewController];
        NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
        ISProduct *product = _products[indexPath.row];
        [c setProduct: product];
    }
}


#pragma mark -
#pragma mark UITableViewDataSource & Delegate

- (CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return 100;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
    return [_products count];
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    ISProductsCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    ISProduct *product = _products[indexPath.row];
    cell.nameLabel.text = product.name;
    cell.detailLabel.text = product.detail;
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    [self performSegueWithIdentifier: @"product" sender: [tableView cellForRowAtIndexPath: indexPath]];
}

@end


@implementation ISProductsCell
@end
