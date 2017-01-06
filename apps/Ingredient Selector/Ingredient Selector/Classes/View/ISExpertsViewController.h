//
//  ISExpertsViewController.h
//  Ingredient Selector
//
//  Created by Alex Romayev on 1/6/17.
//  Copyright © 2017 Alex Romayev. All rights reserved.
//

#import "ISViewController.h"
#import "ISSearchViewController.h"

@protocol ISExpertsViewControllerDelegate <NSObject>
- (ISProductType) productType;
@end


@interface ISExpertsViewController : ISViewController

@property (weak, nonatomic) NSObject<ISExpertsViewControllerDelegate> *delegate;

@end
