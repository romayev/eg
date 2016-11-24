//
//  ISConfectionery.h
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/21/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISProduct.h"

@interface ISConfectionery : ISProduct

@property (nonatomic, readonly) NSString *selectionCriteria;
@property (nonatomic, readonly) NSString *suggestedUsageLevelInFormulations;
@property (nonatomic, readonly) NSString *recommendedMaxUsage;
@property (nonatomic, readonly) NSString *labelDeclaration;

+ (NSArray *) products;

@end
