//
//  ISConfectionerySearchViewController.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/17/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISConfectionerySearchViewController.h"
#import "ISSearchTableViewCell.h"
#import "ISSearchItem.h"
#import "ISConfectionery.h"

@interface ISConfectionerySearchViewController () <ISSearchTableViewCellDataSource, ISSearchTableViewCellDelegate>
@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end


@implementation ISConfectionerySearchViewController {
    NSIndexPath *_editorPath;

    NSArray     *_products;
    NSArray     *_regions;
    NSArray     *_valuePropositions;
    NSArray     *_applications;

    NSMutableArray  *_selectedRegions;
    NSMutableArray  *_selectedValuePropositions;
    NSMutableArray  *_selectedApplications;
}

- (void) awakeFromNib {
    [super awakeFromNib];

    _products = [ISConfectionery products];
    _regions = [ISConfectionery regions];
    _valuePropositions = [ISConfectionery valuePropositions];
    _applications = [ISConfectionery applications];

    _selectedRegions = [NSMutableArray arrayWithObject: [_regions firstObject]];
    _selectedValuePropositions = [NSMutableArray arrayWithObject: [_valuePropositions firstObject]];
    _selectedApplications = [NSMutableArray arrayWithObject: [_applications firstObject]];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"index.title.8", nil);
    _headerLabel.text = NSLocalizedString(@"confectionary.search.instructions", nil);
    _headerLabel.text = [NSString stringWithFormat: @"Products: %zi", [_products count]];
    [_headerLabel sizeToFit];

    UIView *headerView = [_headerLabel superview];
    CGRect frame = [headerView frame];
    frame.size.height = _headerLabel.frame.size.height + 6.0;
    headerView.frame = frame;

    UIEdgeInsets insets = [_tableView contentInset];
    insets.bottom = 44.0;
    [_tableView setContentInset: insets];
    [_tableView setScrollIndicatorInsets: insets];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    UIView *header = [_headerLabel superview];
    CGRect frame = [header frame];
    CGSize size = [_headerLabel sizeThatFits: CGSizeMake(frame.size.width - 30.0, CGFLOAT_MAX)];
    frame.size.height = ceil(size.height) + 8.0;
    [header setFrame: frame];
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
    NSInteger base = 3;
    return base + editor;
}

//- (CGFloat) tableView: (UITableView *) tableView heightForHeaderInSection: (NSInteger) section {
//    return section < 2 ? 38.0 : 0.0;
//}
//
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


- (void) refresh {
    _headerLabel.text = [NSString stringWithFormat: @"Products: %zi", [_products count]];
    [_tableView reloadData];
}

- (NSString *) titleForRow: (NSInteger) row {
    NSString *key = [NSString stringWithFormat: @"%@%zi", @"confectionery.search.title.", row];
    return NSLocalizedString(key, nil);
}

- (NSString *) descriptionForRow: (NSInteger) row {
    switch (row) {
        case 0:
            return [_selectedRegions componentsJoinedByString: @", "];
        case 1:
            return [_selectedValuePropositions componentsJoinedByString: @", "];
        case 2:
            return [_selectedApplications componentsJoinedByString: @", "];
        default:
            return @"Oops";
    }
}

- (NSIndexPath *) editorParentPath {
    return [NSIndexPath indexPathForRow: [_editorPath row] - 1 inSection: [_editorPath section]];
}


#pragma mark -
#pragma mark ISSearchTableViewCellDataSource & Delegate

- (NSArray *) editorItems {
    NSInteger editorRow = [_editorPath row];
    switch (editorRow) {
        case 1:
            return _regions;
        case 2:
            return _valuePropositions;
        case 3:
            return _applications;
        default:
            return nil;
    }
}

- (NSArray *) selectedItemsForCell: (UITableViewCell *) cell {
    NSInteger editorRow = [_editorPath row];
    switch (editorRow) {
        case 1:
            return _selectedRegions;
        case 2:
            return _selectedValuePropositions;
        case 3:
            return _selectedApplications;
        default:
            return 0;
    }
}

- (void) cell: (ISSearchTableViewCell *) cell didSelectCellAtRow: (NSInteger) row {
    NSInteger editorRow = [_editorPath row];
    switch (editorRow) {
        case 1: {
            [self processSelectedIndex: row inArray: _regions withSelected: _selectedRegions];
            [self updateValuePropositions];
            [self updateApplications];
        }
            break;
        case 2: {
            [self processSelectedIndex: row inArray: _valuePropositions withSelected: _selectedValuePropositions];
            [self updateRegions];
            [self updateApplications];
        }
            break;
        case 3: {
            [self processSelectedIndex: row inArray: _applications withSelected: _selectedApplications];
            [self updateRegions];
            [self updateValuePropositions];
        }
            break;
        default:
            break;
    }
    [_tableView reloadRowsAtIndexPaths: @[[self editorParentPath], _editorPath] withRowAnimation: UITableViewRowAnimationAutomatic];
}

- (void) processSelectedIndex: (NSInteger) row inArray: (NSArray *) array withSelected: (NSMutableArray *) selectedArray {
    NSString *selectedValue = array[row];
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
        if ([selectedArray count] == 0 || [selectedArray count] == [array count] - 1) {
            [selectedArray removeAllObjects];
            [selectedArray addObject: kAll];
        }
    }
}

- (void) updateRegions {
    NSDictionary *criteria = @{ @"valueProposition" : _selectedValuePropositions, @"application" : _selectedApplications };
    _regions = [ISConfectionery uniquePropertyValuesForProperty: @"region" withSearchCriteria: criteria];
}

- (void) updateValuePropositions {
    NSDictionary *criteria = @{ @"region" : _selectedRegions, @"application" : _selectedApplications };
    _valuePropositions = [ISConfectionery uniquePropertyValuesForProperty: @"valueProposition" withSearchCriteria: criteria];
}

- (void) updateApplications {
    NSDictionary *criteria = @{ @"region" : _selectedRegions, @"valueProposition" : _selectedValuePropositions };
    _applications = [ISConfectionery uniquePropertyValuesForProperty: @"application" withSearchCriteria: criteria];
}

- (void) cellFinished: (ISSearchTableViewCell *) cell {
//    NSInteger section = [_editorPath section];
//    if (section == 1) {
//        NSInteger row = [_editorPath row];
//        if (row < 4) {
//            row++;
//        } else {
//            row--;
//        }
//
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow: row inSection: section];
//        [self tableView: _tableView didSelectRowAtIndexPath: indexPath];
//    }
}


+ (UIView *) tableSectionHeaderWithTitle: (NSString *) title grouped: (BOOL) grouped {
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(15, grouped ? 0 : 3, 0, 0)];
    if (grouped) {
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    //label.font = [SFFont groupedTableHeaderFont];
    //label.textColor = grouped ? [SFColor darkPurpleColor] : [SFColor grayColor];
    label.text = [title uppercaseString];
    [label sizeToFit];

    // NOTE: Adjust label frame to fix issue with custom fonts (VAGRounded).
    // Font was fixed with ftxdumperfuser, so this adjustment shouldn't be needed anymore.
    // "ftxdumperfuser -t hhea -A d <file.otf>"
    // "ftxdumperfuser -t hhea -A f <file.otf>"
    // http://www.andyyardley.com/2012/04/24/custom-ios-fonts-and-how-to-fix-the-vertical-position-problem/
    CGRect frame = [label frame];
    frame.size.height += 4.0;
    [label setFrame: frame];

    UIView *header = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 0, frame.size.height + (grouped ? 6.0 : 0.0))];
    //header.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    if (!grouped) {
        //header.backgroundColor = [SFColor lightGreyBackgroundColor];
    }
    [header addSubview: label];
    return header;
}

@end
