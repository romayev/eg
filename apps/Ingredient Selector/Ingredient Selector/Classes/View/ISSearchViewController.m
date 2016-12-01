//
//  ISSearchViewController.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/17/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISSearchViewController.h"
#import "ISSearchTableViewCell.h"
#import "ISProductsViewController.h"
#import "ISSearchItem.h"
#import "ISProduct.h"

@interface ISSearchViewController () <ISSearchTableViewCellDataSource, ISSearchTableViewCellDelegate, ISProductsViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) IBOutlet UILabel *productCountLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *viewButton;
@property (strong, readonly, nonatomic) NSArray *products;
@property (strong, nonatomic) NSArray *criteria;
@property (strong, nonatomic) NSMutableArray *availableValues;
@property (strong, nonatomic) NSMutableArray *selectedValues;
@end


@implementation ISSearchViewController {
    NSInteger   _productIndex;
    NSInteger   _count;
    NSIndexPath *_editorPath;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    _productIndex = [_delegate productIndex];
    [self load];
    self.navigationItem.title = NSLocalizedString(@"index.title.8", nil);
    _headerLabel.text = NSLocalizedString(@"product-count", nil);
    _productCountLabel.text = [NSString stringWithFormat: @"%zi", [_products count]];
    [_viewButton setTitle: NSLocalizedString(@"view",  nil) forState: UIControlStateNormal];
}

- (void) encodeRestorableStateWithCoder: (NSCoder *) coder {
    [coder encodeObject: @(_productIndex) forKey: @"idx"];
    [super encodeRestorableStateWithCoder: coder];
}

- (void) decodeRestorableStateWithCoder: (NSCoder *) coder {
    _productIndex = [[coder decodeObjectForKey: @"idx"] integerValue];
    [self load];
    [super decodeRestorableStateWithCoder: coder];
}

- (void) load {
    Class product = [self product];
    _products = [product productsWithSearchCriteria: nil];
    _criteria = [product searchCriteria];
    _count = [_criteria count];
    _availableValues = [[NSMutableArray alloc] initWithCapacity: _count];
    for (NSInteger i = 0; i < _count; i++) {
        NSMutableArray *a = [NSMutableArray array];
        [_availableValues addObject: a];
    }

    // Initialize selected with "All"
    _selectedValues = [[NSMutableArray alloc] initWithCapacity: _count];
    for (NSInteger i = 0; i < _count; i++) {
        NSMutableArray *a = [NSMutableArray array];
        [a addObject: @"All"];
        [_selectedValues addObject: a];
    }

    for (NSInteger i = 0; i < _count; i++) {
        [self updateAvailableValuesAtIndex: i];
    }
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender {
    [super prepareForSegue: segue sender: sender];

    NSString *identifier = [segue identifier];
    if ([identifier isEqualToString: @"products"]) {
        ISProductsViewController *c = [segue destinationViewController];
        [c setDelegate: self];
    }
}


#pragma mark -
#pragma mark UI Actions

- (IBAction) done: (id) sender {
}


#pragma mark -
#pragma mark UITableViewDataSource & Delegate

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
    const NSInteger editorSection = _editorPath ? [_editorPath section] : NSNotFound;
    const NSInteger editor = (section == editorSection) ? 1 : 0;
    return _count + editor;
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    const NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    const NSInteger editorSection = _editorPath ? [_editorPath section] : NSNotFound;
    const NSInteger editorRow = _editorPath ? [_editorPath row] : NSNotFound;
    if (section == editorSection && row == editorRow) {
        NSArray *items = [self editorItems];
        return 44.0 * [items count];
    }

    return 44.0;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    const NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    const NSInteger editorSection = _editorPath ? [_editorPath section] : NSNotFound;
    const NSInteger editorRow = _editorPath ? [_editorPath row] : NSNotFound;
    if (section == editorSection && row == editorRow) {
        NSString *cellIdentifier = @"DropDown";
        ISSearchTableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier forIndexPath: indexPath];
        [cell setDelegate: self];
        [cell update];
        return cell;
    }
    if (section == editorSection && row > editorRow) {
        row--;
    }

    NSString *title;
    NSString *detail;
    title = [self titleForRow: row];
    detail = [self descriptionForRow: row];
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;

    return cell;
}
- (BOOL) tableView: (UITableView *) tableView shouldHighlightRowAtIndexPath: (NSIndexPath *) indexPath {
    if (_editorPath) {
        return [indexPath section] != [_editorPath section] || [indexPath row] != [_editorPath row];
    }

    return YES;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    const NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    [tableView deselectRowAtIndexPath: indexPath animated: YES];

    NSIndexPath * const editorPath = _editorPath;
    const NSInteger editorSection = editorPath ? [editorPath section] : NSNotFound;
    const NSInteger editorRow = editorPath ? [editorPath row] : NSNotFound;
    if (editorPath) {
        _editorPath = nil;
        [tableView deleteRowsAtIndexPaths: @[editorPath] withRowAnimation: UITableViewRowAnimationFade];
        if (section == editorSection && row > editorRow) {
            row--;
        }
    }

    BOOL edit = NO;
    edit = (section != editorSection || (row + 1) != editorRow);

    if (edit) {
        _editorPath = [NSIndexPath indexPathForRow: (row + 1) inSection: section];
        [tableView insertRowsAtIndexPaths: @[_editorPath] withRowAnimation: UITableViewRowAnimationFade];
        [tableView scrollToRowAtIndexPath: [self editorParentPath] atScrollPosition: UITableViewScrollPositionNone animated: YES];
    }
}


#pragma mark -
#pragma mark Helpers


- (Class) product {
    return NSClassFromString(@"ISConfectionery");
}

- (NSString *) titleForRow: (NSInteger) row {
    NSString *key = [NSString stringWithFormat: @"%@%zi", @"confectionery.search.title.", row];
    return NSLocalizedString(key, nil);
}

- (NSString *) descriptionForRow: (NSInteger) row {
    if (row >= [_selectedValues count]) return nil;
    NSArray *selected = _selectedValues[row];
    return [selected componentsJoinedByString: @", "];
}

- (NSIndexPath *) editorParentPath {
    return [NSIndexPath indexPathForRow: [_editorPath row] - 1 inSection: [_editorPath section]];
}


#pragma mark -
#pragma mark ISSearchTableViewCellDataSource & Delegate

- (NSArray *) editorItems {
    NSInteger editorRow = [_editorPath row];
    if (editorRow - 1 >= [_availableValues count]) return nil;
    return _availableValues[editorRow - 1];
}

- (NSArray *) selectedItemsForCell: (UITableViewCell *) cell {
    NSInteger editorRow = [_editorPath row];
    if (editorRow - 1 >= [_availableValues count]) return nil;
    return _selectedValues[editorRow - 1];
}

- (void) cell: (ISSearchTableViewCell *) cell didSelectCellAtRow: (NSInteger) row {
    NSInteger editorRow = [_editorPath row];
    NSInteger editorParentRow = editorRow - 1;

    // Process current selection
    [self processSelectedRow: row atIndex: editorParentRow];

    for (NSInteger i = 0; i < _count; i++) {
        if (i == editorParentRow) continue;
        [self updateAvailableValuesAtIndex: i];
    }
    [_tableView reloadRowsAtIndexPaths: @[[self editorParentPath], _editorPath] withRowAnimation: UITableViewRowAnimationAutomatic];
    [self updateProdutcs];
}

- (void) processSelectedRow: (NSInteger) row atIndex: (NSInteger) idx {
    NSArray *availableValues = _availableValues[idx];
    NSMutableArray *selectedArray = _selectedValues[idx];
    NSString *selectedValue = availableValues[row];
    if ([selectedValue isEqualToString: kAll]) {
        [selectedArray removeAllObjects];
        [selectedArray addObject: kAll];
    } else {
        [selectedArray removeObject: kAll];
        if ([selectedArray containsObject: selectedValue]) {
            [selectedArray removeObject: selectedValue];
        } else {
            [selectedArray addObject: selectedValue];
        }
        if ([selectedArray count] == 0 || [selectedArray count] == [availableValues count] - 1) {
            [selectedArray removeAllObjects];
            [selectedArray addObject: kAll];
        }
    }
}

- (void) updateProdutcs {
    NSMutableDictionary *criteria = [NSMutableDictionary dictionaryWithCapacity: _count];
    for (NSInteger i = 0; i < _count; i++) {
        [criteria setObject: _selectedValues[i] forKey: _criteria[i]];
    }
    _products = [[self product] productsWithSearchCriteria: criteria];
    _headerLabel.text = NSLocalizedString(@"product-count", nil);
    _productCountLabel.text = [NSString stringWithFormat: @"%zi", [_products count]];
    [_viewButton setTitle: NSLocalizedString(@"view",  nil) forState: UIControlStateNormal];
}

- (void) updateAvailableValuesAtIndex: (NSInteger) idx {
    // Create a dictionary of criteria that includes all other selected values
    NSMutableDictionary *criteria = [NSMutableDictionary dictionaryWithCapacity: _count - 1];
    for (NSInteger i = 0; i < _count; i++) {
        if (i == idx) continue;
        [criteria setObject: _selectedValues[i] forKey: _criteria[i]];
    }
    // Update available values at the passed in index
    _availableValues[idx] = [[self product] uniquePropertyValuesForProperty: _criteria[idx] withSearchCriteria: criteria];
}

@end
