//
//  ISBeverage.h
//  Ingredient Selector
//
//  Created by Alex Romayev on 12/5/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISProduct.h"

@interface ISBeverage : ISProduct

@property (readonly, nonatomic) NSString *segment;
@property (readonly, nonatomic) NSString *base;
@property (readonly, nonatomic) NSString *starchUseLabel;
@property (readonly, nonatomic) NSString *fatContent;
@property (readonly, nonatomic) NSString *proteinContent;
@property (readonly, nonatomic) NSString *features;
@property (readonly, nonatomic) NSString *productDescription;

@end
