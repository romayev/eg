//
//  ISBeverage.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 12/5/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISBeverage.h"

@implementation ISBeverage


+ (NSArray *) products {
    static NSArray *__products;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *products = [NSMutableArray array];
        NSArray *data = [[NSArray alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"beverages" ofType: @"plist"]];
        for (NSDictionary *plist in data) {
            ISBeverage *product = [[ISBeverage alloc] initWithPlist: plist];
            [products addObject: product];
        }

        NSSortDescriptor *prioritySort = [NSSortDescriptor sortDescriptorWithKey: @"priority" ascending: YES];
        NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name" ascending: YES];

        __products = [products sortedArrayUsingDescriptors: @[prioritySort, nameSort]];
    });
    return __products;
}

- (NSArray *) displayAttributes {
    return @[@"base", @"labelDeclaration", @"regions", @"starchUseLabel", @"valuePropositions", @"fatContent", @"proteinContent", @"features", @"productDescription"];
}

+ (NSString *) moduleName {
    return @"beverages";
}

+ (NSArray *) searchCriteria {
    return @[ @"region", @"segment", @"valueProposition", @"labelDeclaration", @"base" ];
}

- (id) initWithPlist: (NSDictionary *) plist {
    if (self = [super initWithPlist: plist]) {
        _segment = plist[@"segment"];
        _base = plist[@"base"];
        _starchUseLabel = plist[@"starchUseLabel"];
        _fatContent = plist[@"fatContent"];
        _proteinContent = plist[@"proteinContent"];
        _features = plist[@"features"];
        _productDescription = plist[@"productDescription"];
    }
    return self;
}

@end
