//
//  ISSearchViewController.h
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/17/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISViewController.h"

typedef enum {
    ISYogurt,
    ISProcessedCheese,
    ISCreamySalad,
    ISCarrageenan,
    ISBeverages,
    ISMeat,
    ISBattersAndBreadings,
    ISHydrocolloids,
    ISConfectionery,
    ISTomatoBasedSauses,
    ISThickener
} ISProductType;


@protocol ISSearchViewControllerDelegate <NSObject>
- (ISProductType) productType;
@end

@interface ISSearchViewController : ISViewController

@property (nonatomic, weak) NSObject<ISSearchViewControllerDelegate> *delegate;

@end
