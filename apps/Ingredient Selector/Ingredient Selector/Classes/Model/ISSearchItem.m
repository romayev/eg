//
//  ISRegion.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/19/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISSearchItem.h"

@implementation ISSearchItem

+ (NSArray *) regions {
    static NSArray *__regions;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *regions = [NSMutableArray array];
        NSArray *data = [[NSArray alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"regions" ofType: @"plist"]];
        for (NSDictionary *dict in data) {
            ISSearchItem *region = [[ISSearchItem alloc] initWithDictionary: dict];
            [regions addObject: region];
        }
        __regions = [regions copy];
    });
    return __regions;
}

+ (NSArray *) valuePropositions {
    static NSArray *__valuePropositions;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *valuePropositions = [NSMutableArray array];
        NSArray *data = [[NSArray alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"confectionery-value-propositions" ofType: @"plist"]];
        for (NSDictionary *dict in data) {
            ISSearchItem *valueProposition = [[ISSearchItem alloc] initWithDictionary: dict];
            [valuePropositions addObject: valueProposition];
        }
        __valuePropositions = [valuePropositions copy];
    });
    return __valuePropositions;
}

+ (NSArray *) applications {
    static NSArray *__applications;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *applications = [NSMutableArray array];
        NSArray *data = [[NSArray alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"confectionery-applications" ofType: @"plist"]];
        for (NSDictionary *dict in data) {
            ISSearchItem *application = [[ISSearchItem alloc] initWithDictionary: dict];
            [applications addObject: application];
        }
        __applications = [applications copy];
    });
    return __applications;
}

- (id) initWithDictionary: (NSDictionary *) dictionary {
    if (self = [super init]) {
        _itemID = [dictionary[@"id"] integerValue];
        _title = dictionary[@"title"];
    }
    return self;
}

@end
