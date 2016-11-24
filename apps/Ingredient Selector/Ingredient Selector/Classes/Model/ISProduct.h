//
//  ISProduct.h
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/21/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISProduct : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *detail;
@property (nonatomic, readonly) NSString *notes;
@property (nonatomic, readonly) NSString *region;
@property (nonatomic, readonly) NSString *valueProposition;
@property (nonatomic, readonly) NSString *application;

- (id) initWithPlist: (NSDictionary *) plist;

+ (NSArray *) products;
+ (NSArray *) regions: (NSArray *) products;
+ (NSArray *) applications: (NSArray *) products;

+ (NSArray *) valuePropositions: (NSArray *) products;
+ (NSArray *) productsWithRegion: (NSString *) region inArray: (NSArray *) array;
+ (NSArray *) productsWithValueProposition: (NSString *) valueProposition inArray: (NSArray *) array;
+ (NSArray *) productsWithApplication: (NSString *) application inArray: (NSArray *) array;

@end
