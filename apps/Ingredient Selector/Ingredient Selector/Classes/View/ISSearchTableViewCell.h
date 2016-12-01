//
//  ISSearchTableViewCell.h
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/18/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ISSearchTableViewCellDataSource;
@protocol ISSearchTableViewCellDelegate;


@interface ISSearchTableViewCell : UITableViewCell


@property (nonatomic, weak) IBOutlet id<ISSearchTableViewCellDataSource, ISSearchTableViewCellDelegate> delegate;
@property (strong, nonatomic) NSArray *items;

- (void) update;

@end


@protocol ISSearchTableViewCellDataSource

- (NSArray *) editorItems;
- (NSArray *) selectedItemsForCell: (UITableViewCell *) cell;
@end


@protocol ISSearchTableViewCellDelegate

- (void) cell: (ISSearchTableViewCell *) cell didSelectCellAtRow: (NSInteger) row;

@end


