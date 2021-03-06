//
//  ISConfectionery.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/21/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISConfectionery.h"

@implementation ISConfectionery

+ (NSArray *) products {
    static NSArray *__products;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *products = [NSMutableArray array];
        NSArray *data = [[NSArray alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"confectionery" ofType: @"plist"]];
        for (NSDictionary *plist in data) {
            ISConfectionery *product = [[ISConfectionery alloc] initWithPlist: plist];
            [products addObject: product];
        }

        NSSortDescriptor *prioritySort = [NSSortDescriptor sortDescriptorWithKey: @"priority" ascending: YES];
        NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name" ascending: YES];

        __products = [products sortedArrayUsingDescriptors: @[prioritySort, nameSort]];
    });
    return __products;
}

- (NSArray *) displayAttributes {
    return @[@"regions", @"valuePropositions", @"applications", @"notes", @"labelDeclaration", @"selectionCriteria", @"recommendedMaxUsage"];
}

- (NSString *) applications {
    return [self valuesForProperty: @"application"];
}

+ (NSString *) moduleName {
    return @"confectionery";
}

+ (NSArray *) searchCriteria {
    return @[ @"region", @"valueProposition", @"application" ];
}

- (id) initWithPlist: (NSDictionary *) plist {
    if (self = [super initWithPlist: plist]) {
        _application = plist[@"application"];
        _selectionCriteria = plist[@"selectionCriteria"];
        _suggestedUsageLevelInFormulations = plist[@"suggestedUsageLevelInFormulations"];
        _recommendedMaxUsage = plist[@"recommendedMaxUsage"];
    }
    return self;
}

@end
