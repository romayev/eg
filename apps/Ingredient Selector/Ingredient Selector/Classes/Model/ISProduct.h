//
//  ISProduct.h
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/21/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kAll @"All"


@interface ISProduct : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *detail;
@property (nonatomic, readonly) NSString *notes;
@property (nonatomic, readonly) NSString *region;
@property (nonatomic, readonly) NSString *valueProposition;
@property (nonatomic, readonly) NSString *application;

- (id) initWithPlist: (NSDictionary *) plist;

+ (NSArray *) products;

+ (NSArray *) productsWithSearchCriteria: (NSDictionary *) searchCriteria;
+ (NSArray *) uniquePropertyValuesForProperty: (NSString *) property withSearchCriteria: (NSDictionary *) searchCriteria;

+ (NSArray *) regions;
+ (NSArray *) applications;
+ (NSArray *) valuePropositions;

+ (BOOL) isAll: (NSArray *) criteria;

@end
