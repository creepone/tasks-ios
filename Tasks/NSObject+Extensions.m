//
//  NSObject+PWObject.m
//  Tasks
//
//  Created by Tomas Vana on 3/15/12.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "NSObject+Extensions.h"

@implementation NSObject(Extensions)

- (void)iaa_performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    int64_t delta = (int64_t)(1.0e9 * delay);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), block);
}

- (id)iaa_nilIfNull
{
    return [self isEqual:[NSNull null]] ? nil : self;
}

@end