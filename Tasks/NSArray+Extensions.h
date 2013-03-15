//
//  NSArray+Extensions.h
//  Tasks
//
//  Created by Tomas Vana on 3/15/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray(Extensions)

- (NSArray *)iaa_mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;

@end
