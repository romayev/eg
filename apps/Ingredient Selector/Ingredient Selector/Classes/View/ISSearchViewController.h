//
//  ISSearchViewController.h
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/17/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISViewController.h"

@protocol ISSearchViewControllerDelegate <NSObject>
- (NSInteger) productIndex;
@end

@interface ISSearchViewController : ISViewController

@property (nonatomic, weak) NSObject<ISSearchViewControllerDelegate> *delegate;

@end
