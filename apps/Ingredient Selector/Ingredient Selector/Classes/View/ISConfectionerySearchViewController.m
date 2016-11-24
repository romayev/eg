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
    NSInteger   _mode;
    NSIndexPath *_editorPath;

    NSArray     *_products;
    NSArray     *_regions;
    NSArray     *_valuePropositions;
    NSArray     *_applications;

    NSArray     *_selectedRegions;
    NSArray     *_selectedValuePropositions;
    NSArray     *_selectedApplications;
}

- (void) awakeFromNib {
    [super awakeFromNib];

    _products = [ISConfectionery products];
    _regions = [ISProduct regions: _products];
    _valuePropositions = [ISProduct valuePropositions: _products];
    _applications = [ISProduct applications: _products];

    _selectedRegions = [NSArray arrayWithObject: [_regions firstObject]];
    _selectedValuePropositions = [NSArray arrayWithObject: [_valuePropositions firstObject]];
    _selectedApplications = [NSArray arrayWithObject: [_applications firstObject]];
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
    _regions = [ISProduct regions: _products];
    _valuePropositions = [ISProduct valuePropositions: _products];
    _applications = [ISProduct applications: _products];
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

- (NSInteger) selectedItemForCell: (UITableViewCell *) cell {
    NSInteger editorRow = [_editorPath row];
    switch (editorRow) {
        case 1:
            return [_regions indexOfObject: [_selectedRegions firstObject]];
        case 2:
            return [_valuePropositions indexOfObject: [_selectedValuePropositions firstObject]];
        case 3:
            return [_applications indexOfObject: [_selectedApplications firstObject]];
        default:
            return 0;
    }
}

- (void) cell: (ISSearchTableViewCell *) cell didSelectCellAtRow: (NSInteger) row {
    NSInteger editorRow = [_editorPath row];
    switch (editorRow) {
        case 1: {
            NSString *region = _regions[row];
            _selectedRegions = [NSArray arrayWithObject: region];
            _products = [ISProduct productsWithRegion: region inArray: _products];
        }
            break;
        case 2: {
            NSString *valueProposition = _valuePropositions[row];
            _selectedValuePropositions = [NSArray arrayWithObject: valueProposition];
            _products = [ISProduct productsWithValueProposition: valueProposition inArray: _products];
        }
            break;
        case 3: {
            NSString *application = _applications[row];
            _selectedApplications = [NSArray arrayWithObject: application];
            _products = [ISProduct productsWithApplication: application inArray: _products];
        }
        default:
            break;
    }
    [self refresh];
    //[_tableView reloadRowsAtIndexPaths: @[[self editorParentPath], _editorPath] withRowAnimation: UITableViewRowAnimationAutomatic];
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
