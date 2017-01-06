//
//  ISProductsViewController.h
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/25/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISViewController.h"
#import "ISSearchViewController.h"

@protocol ISProductsViewControllerDelegate <NSObject>
- (NSArray *) products;
- (BOOL) usePriority;
- (ISProductType) productType;
@end

@interface ISProductsViewController : ISViewController

@property (weak, nonatomic) NSObject<ISProductsViewControllerDelegate> *delegate;

@end
