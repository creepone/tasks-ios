//
//  NSSet+Extensions.m
//  Tasks
//
//  Created by Tomas Vana on 3/16/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "NSSet+Extensions.h"

@implementation NSSet (Extensions)

- (NSSet*)intersection:(NSSet*)otherSet
{
    NSMutableSet *intersection = [self mutableCopy];
	[intersection intersectSet:otherSet];
	return intersection;
}

- (NSSet*)difference:(NSSet*)otherSet
{
    NSMutableSet *difference = [self mutableCopy];
    [difference minusSet:otherSet];
    return difference;
}

@end
