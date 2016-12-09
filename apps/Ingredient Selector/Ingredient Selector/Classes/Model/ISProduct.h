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
@property (readonly, nonatomic) NSNumber *priority;
@property (readonly, nonatomic) NSString *regions;
@property (readonly, nonatomic) NSString *valuePropositions;
@property (readonly, nonatomic) NSString *labelDeclaration;
@property (readonly, nonatomic) NSArray *displayAttributes;

- (id) initWithPlist: (NSDictionary *) plist;

+ (NSString *) moduleName;
+ (NSArray *) products;
+ (NSArray *) searchCriteria;
+ (BOOL) usesPriority;

+ (NSArray *) productsWithSearchCriteria: (NSDictionary *) searchCriteria;
+ (NSArray *) uniquePropertyValuesForProperty: (NSString *) property withSearchCriteria: (NSDictionary *) searchCriteria;

+ (BOOL) isAll: (NSArray *) criteria;

// Protected
- (NSString *) valuesForProperty: (NSString *) property;

@end
