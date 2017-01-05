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
        _priority = [plist[@"priority"] integerValue];
        _labelDeclaration = plist[@"labelDeclaration"];
    }
    return self;
}

- (BOOL) isEqual: (id) object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass: [ISProduct class]]) {
        return NO;
    }
    return [self.name isEqualToString: ((ISProduct *) object).name];
}

- (NSUInteger) hash {
    return [self.name hash];
}

- (NSArray *) displayAttributes {
    return nil;
}

- (NSString *) regions {
    return [self valuesForProperty: @"region"];
}

- (NSString *) valuePropositions {
    return [self valuesForProperty: @"valueProposition"];
}

- (NSString *) valuesForProperty: (NSString *) property {
    NSPredicate *p = [NSPredicate predicateWithFormat: @"name = %@", _name];
    NSArray *products = [[[self class] products] filteredArrayUsingPredicate: p];
    NSArray *values = [products valueForKeyPath: [NSString stringWithFormat: @"@distinctUnionOfObjects.%@", property]];
    NSArray *sorted = [values sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
    return [sorted componentsJoinedByString: @", "];
}

+ (NSString *) moduleName {
    return @"product";
}

+ (NSArray *) products {    
    return nil;
}

+ (NSArray *) searchCriteria {
    return nil;
}

+ (BOOL) usesPriority {
    NSString *keypath = [NSString stringWithFormat: @"@distinctUnionOfObjects.%@", @"priority"];
    NSArray *unique = [[self products] valueForKeyPath: keypath];
    return [unique count] > 1; // empty
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
    if (searchCriteria != nil) {
        NSMutableArray *predicates = [NSMutableArray array];
        for (NSString *key in [searchCriteria allKeys]) {
            NSArray *criteria = searchCriteria[key];
            if (![self isAll: criteria]) {
                NSPredicate *p = [NSPredicate predicateWithFormat: @"%K IN %@", key, criteria];
                [predicates addObject: p];
            }
        }
        if ([predicates count] > 0) {
            NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates: predicates];
            products = [products filteredArrayUsingPredicate: predicate];
        }
    }

    NSSet *unique = [NSSet setWithArray: products];
    NSSortDescriptor *prioritySort = [NSSortDescriptor sortDescriptorWithKey: @"priority" ascending: YES];
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name" ascending: YES];
    return [[unique allObjects] sortedArrayUsingDescriptors: @[prioritySort, nameSort]];
}

+ (NSArray *) productsWithHighPriority: (NSArray *) products {
    NSMutableArray *highPriorityProducts = [NSMutableArray arrayWithCapacity: [products count]];
    NSInteger count = 0;
    ISProduct *first = [products firstObject];
    NSInteger highestPriority = [first priority];
    for (ISProduct *product in products) {
        BOOL isHighPriority = [product priority] == highestPriority;
        if (isHighPriority || (!isHighPriority && count < 5)) {
            [highPriorityProducts addObject: product];
        } else {
            break;
        }
        count++;
    }
    return [highPriorityProducts copy];
}

+ (BOOL) isAll: (NSArray *) criteria {
    if (criteria == nil) return YES;
    NSInteger count = [criteria count];
    return count == 1 && [[criteria firstObject] isEqualToString: kAll];
}

@end
