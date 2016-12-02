//
//  ISProductViewController.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/25/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISProductViewController.h"
#import "ISConfectionery.h"


@interface ISProductAttributeCell :  UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@end


@interface ISProductViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *attributes;
@end


@implementation ISProductViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 100;
    _tableView.alwaysBounceVertical = NO;

    NSArray *allAttributes = @[@"productNotes", @"selectionCriteria", @"recommendedMaxUsage", @"labelDeclaration"];
    NSMutableArray *attributes = [NSMutableArray arrayWithCapacity: [allAttributes count]];

    NSDictionary *attributesDict = _product.attributes;
    for (NSString *key in allAttributes) {
        NSString *value = attributesDict[key];
        if (value.length > 0) {
            [attributes addObject: key];
        }
    }
    _attributes = [attributes copy];
}

- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
    self.title = _product.name;
}

- (void) viewDidAppear: (BOOL) animated {
    [super viewDidAppear: animated];
    [_tableView reloadData];
}


#pragma mark -
#pragma mark UITableViewDelegate and DataSource

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
    return [_attributes count] + 1;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    static NSString *__nameCell = @"ProductNameCell";
    static NSString *__attributeCell = @"ProductAttributeCell";
    NSInteger row = [indexPath row];
    ISProductAttributeCell *cell = [tableView dequeueReusableCellWithIdentifier: row == 0 ? __nameCell : __attributeCell forIndexPath: indexPath];

    if (row == 0) {
        cell.titleLabel.text = _product.name;
        cell.detailLabel.text = _product.detail;
    } else {
        NSString *attribute = _attributes[row - 1];
        NSString *key = [@"product.attribute." stringByAppendingString: attribute];
        cell.titleLabel.text = NSLocalizedString(key, nil);
        cell.detailLabel.text = [_product.attributes objectForKey: attribute];
    }
    return cell;
}

@end


@implementation ISProductAttributeCell
@end
