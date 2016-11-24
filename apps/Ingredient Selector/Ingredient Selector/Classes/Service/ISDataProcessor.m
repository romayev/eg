//
//  ISDataProcessor.m
//  Ingredient Selector
//
//  Created by Alex Romayev on 11/14/16.
//  Copyright © 2016 Alex Romayev. All rights reserved.
//

#import "ISDataProcessor.h"

// Regions
#define kTomatoRegionRowIdx         2
#define kTomatoRegionFirstColIdx    3
#define kTomatoRegionLastColIdx     7

#define kTomatoBaseColIdx           2
#define kTomatoIngrTypeColIdx       8

// Data
#define kTomatoDataRowIdx           0

@implementation ISDataProcessor

+ (void) process {
    return;
    NSString *content = [self contentFromCVSFileNamed: @"Confectionery_CSV_MS-DOS"];
    NSArray *data = [self dataFromContent: content];

    NSMutableArray *regions = [NSMutableArray arrayWithCapacity: kTomatoRegionLastColIdx - kTomatoRegionFirstColIdx + 1];
    for (NSInteger colIdx = kTomatoRegionFirstColIdx; colIdx <= kTomatoRegionLastColIdx; colIdx++) {
        [regions addObject: data[kTomatoRegionRowIdx][colIdx]];
    }
    NSLog(@"REGIONS: %@", regions);

    NSSet *bases = [self uniqueValuesInCol: kTomatoBaseColIdx withData: data];
    NSLog(@"BASES: %@", bases);

    NSSet *types = [self uniqueValuesInCol: kTomatoIngrTypeColIdx withData: data];
    NSLog(@"TYPES: %@", types);
}

+ (NSSet *) uniqueValuesInCol: (NSInteger) col withData: (NSArray *) data {
    NSMutableSet *values = [NSMutableSet set];
    for (NSInteger rowIdx = kTomatoRegionRowIdx; rowIdx < [data count]; rowIdx++) {
        id value = data[rowIdx][col];
        if (value == [NSNull null]) {
            continue;
        }
        [values addObject: value];
    }
    return [values copy];
}

+ (NSArray *) dataFromContent: (NSString *) content {
    const NSMutableArray *data = [NSMutableArray array];
    NSCharacterSet *newline = [NSCharacterSet newlineCharacterSet];
    const NSScanner *scanner = [NSScanner scannerWithString: content];
    while (![scanner isAtEnd]) {
        NSString *row;
        [scanner scanUpToCharactersFromSet: newline intoString: &row];
        NSArray *values = [self valuesFromRow: row];
        [data addObject: values];
    }
    return [data copy];
}

+ (NSArray *) valuesFromRow: (NSString *) row {
    NSMutableArray *values = [NSMutableArray array];

    NSArray *data = [row componentsSeparatedByString: @","];
    for (NSString *value in data) {
        [values addObject: value == nil ? [NSNull null] : value];
    }
    return values;
}

+ (NSArray *) scannedValuesFromRow: (NSString *) row {
    NSMutableArray *values = [NSMutableArray array];
    NSCharacterSet *separator = [NSCharacterSet characterSetWithCharactersInString: @","];
    const NSScanner *scanner = [NSScanner scannerWithString: row];
    while (![scanner isAtEnd]) {
        NSString *value;
        [scanner scanUpToCharactersFromSet: separator intoString: &value];
        [values addObject: value == nil ? [NSNull null] : value];
    }
    return [values copy];
}

+ (NSString *) contentFromCVSFileNamed: (NSString *) fileName {
    NSString *path = [[NSBundle mainBundle] pathForResource: fileName ofType: @"csv"];
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile: path encoding: NSASCIIStringEncoding error: &error];
    if (error) {
        NSLog(@"Error: %@", error);
    }
    return content;
}

@end
