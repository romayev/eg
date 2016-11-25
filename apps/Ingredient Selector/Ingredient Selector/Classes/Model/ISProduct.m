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

+ (NSArray *) regions {
    return [self uniqueValuesWithProperty: @"region" products: [self products]];
}

+ (NSArray *) valuePropositions {
    return [self uniqueValuesWithProperty: @"valueProposition" products: [self products]];
}

+ (NSArray *) applications {
    return [self uniqueValuesWithProperty: @"application" products: [self products]];
}

+ (NSArray *) uniquePropertyValuesForProperty: (NSString *) property withSearchCriteria: (NSDictionary *) searchCriteria {
    NSArray *products = [self productsWithSearchCriteria: searchCriteria];
    return [self uniqueValuesWithProperty: property products: products];
}

+ (NSArray *) uniqueValuesWithProperty: (NSString *) property products: (NSArray *) products {
    NSString *keypath = [NSString stringWithFormat: @"@distinctUnionOfObjects.%@", property];
    NSArray *unique = [products valueForKeyPath: keypath];
    NSArray *sorted = [unique sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
    NSMutableArray *array = [NSMutableArray arrayWithArray: sorted];
    [array insertObject: NSLocalizedString(@"all", nil) atIndex: 0];
    return [array copy];
}

+ (NSArray *) productsWithSearchCriteria: (NSDictionary *) searchCriteria {
    NSArray *products = [self products];

    NSMutableArray *predicates = [NSMutableArray array];
    for (NSString *key in [searchCriteria allKeys]) {
        NSArray *criteria = searchCriteria[key];
        if (![self isAll: criteria]) {
            NSPredicate *p = [NSPredicate predicateWithFormat: @"%K IN %@", key, criteria];
            [predicates addObject: p];
        }
    }
    if ([predicates count] == 0) return products;

    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates: predicates];
    return [products filteredArrayUsingPredicate: predicate];
}

+ (BOOL) isAll: (NSArray *) criteria {
    if (criteria == nil) return YES;
    NSInteger count = [criteria count];
    return count == 1 && [[criteria firstObject] isEqualToString: kAll];
}

@end
