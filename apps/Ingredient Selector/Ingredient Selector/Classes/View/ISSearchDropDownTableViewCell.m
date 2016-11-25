//
//  ISSearchDropDownTableViewCell.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/18/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISSearchDropDownTableViewCell.h"
#import "ISSearchItem.h"

@interface ISSearchDropDownTableViewCell () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end


@implementation ISSearchDropDownTableViewCell
- (void) awakeFromNib {
    [super awakeFromNib];
    [_tableView setRowHeight: 44.0];
}

- (void) update {
    [self setItems: [[self delegate] editorItems]];
    [_tableView reloadData];
}


#pragma mark -
#pragma mark UITableViewDataSource & Delegate

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
    return [[self items] count];
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    const NSInteger row = [indexPath row];

    NSArray *items = [self items];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    NSArray *selected = [[self delegate] selectedItemsForCell: self];
    BOOL checked = [selected containsObject: items[row]];

    NSString *title = items[row];
    cell.textLabel.text = title;
    cell.accessoryType = checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    const NSInteger row = [indexPath row];
    BOOL all = row == 0;

    for (NSInteger other = 0; other < [[self items] count]; other ++) {
        NSIndexPath *otherPath = [NSIndexPath indexPathForRow: other inSection: 0];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath: otherPath];
        BOOL checked = (all && other == 0) || (!all && other == row);
        [cell setAccessoryType: checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
    }
   [[self delegate] cell: self didSelectCellAtRow: row];

    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

@end
