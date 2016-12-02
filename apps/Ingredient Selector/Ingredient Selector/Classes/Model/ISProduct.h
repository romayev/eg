//
//  ISProduct.h
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/21/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kAll @"All"


@interface ISProduct : NSObject {
    NSDictionary *_attributes;
}

@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *detail;
@property (readonly, nonatomic) NSString *notes;
@property (readonly, nonatomic) NSString *region;
@property (readonly, nonatomic) NSString *valueProposition;
@property (readonly, nonatomic) NSString *application;
@property (readonly, nonatomic) NSNumber *priority;
@property (readonly, nonatomic) NSDictionary *attributes;

- (id) initWithPlist: (NSDictionary *) plist;

+ (NSArray *) products;
+ (NSArray *) searchCriteria;

+ (NSArray *) productsWithSearchCriteria: (NSDictionary *) searchCriteria;
+ (NSArray *) uniquePropertyValuesForProperty: (NSString *) property withSearchCriteria: (NSDictionary *) searchCriteria;

+ (NSArray *) regions;
+ (NSArray *) applications;
+ (NSArray *) valuePropositions;

+ (BOOL) isAll: (NSArray *) criteria;

@end
