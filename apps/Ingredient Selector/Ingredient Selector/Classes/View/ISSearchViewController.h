//
//  ISSearchViewController.h
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/17/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISViewController.h"

typedef enum {
    ISBattersAndBreadings,
    ISBeverages,
    ISCarrageenan,
    ISConfectionery,
    ISCreamySalad,
    ISHydrocolloids,
    ISMeat,
    ISProcessedCheese,
    ISYogurt,
    ISTomatoBasedSauses,
    ISProductTypeCount
} ISProductType;


@protocol ISSearchViewControllerDelegate <NSObject>
- (ISProductType) productType;
@end

@interface ISSearchViewController : ISViewController

@property (nonatomic, weak) NSObject<ISSearchViewControllerDelegate> *delegate;

@end
