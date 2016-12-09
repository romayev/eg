//
//  ISConfectionery.h
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/21/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISProduct.h"

@interface ISConfectionery : ISProduct

@property (readonly, nonatomic) NSString *application;
@property (readonly, nonatomic) NSString *selectionCriteria;
@property (readonly, nonatomic) NSString *suggestedUsageLevelInFormulations;
@property (readonly, nonatomic) NSString *recommendedMaxUsage;
@property (readonly, nonatomic) NSString *applications;

+ (NSArray *) products;

@end
