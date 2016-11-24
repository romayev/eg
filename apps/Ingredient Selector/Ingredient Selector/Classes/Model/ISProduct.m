//
//  ISProduct.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/21/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISProduct.h"

@implementation ISProduct

- (id) initWithPlist: (NSDictionary *) plist {
    if (self = [super init]) {
        _name = plist[@"productName"];
        _detail = plist[@"productDescription"];
        _notes = plist[@"productNotes"];
        _region = plist[@"region"];
        _valueProposition = plist[@"valueProposition"];
        _application = plist[@"application"];
    }
    return self;
}

+ (NSArray *) products {
    return nil;
}

+ (NSArray *) regions: (NSArray *) products {
    return [self uniqueValuesWithProperty: @"region" products: products];
}

+ (NSArray *) valuePropositions: (NSArray *) products {
    return [self uniqueValuesWithProperty: @"valueProposition" products: products];
}

+ (NSArray *) applications: (NSArray *) products {
    return [self uniqueValuesWithProperty: @"application" products: products];
}

+ (NSArray *) uniqueValuesWithProperty: (NSString *) property products: (NSArray *) products {
    NSString *keypath = [NSString stringWithFormat: @"@distinctUnionOfObjects.%@", property];
    NSArray *unique = [products valueForKeyPath: keypath];
    NSArray *sorted = [unique sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
    NSMutableArray *array = [NSMutableArray arrayWithArray: sorted];
    [array insertObject: NSLocalizedString(@"all", nil) atIndex: 0];
    return [array copy];
}

+ (NSArray *) productsWithRegion: (NSString *) region inArray: (NSArray *) array {
    NSPredicate *p = [NSPredicate predicateWithFormat: @"region = %@", region];
    return [array filteredArrayUsingPredicate: p];
}

+ (NSArray *) productsWithValueProposition: (NSString *) valueProposition inArray: (NSArray *) array {
    NSPredicate *p = [NSPredicate predicateWithFormat: @"valueProposition = %@", valueProposition];
    return [array filteredArrayUsingPredicate: p];
}

+ (NSArray *) productsWithApplication: (NSString *) application inArray: (NSArray *) array {
    NSPredicate *p = [NSPredicate predicateWithFormat: @"application = %@", application];
    return [array filteredArrayUsingPredicate: p];
}

@end
