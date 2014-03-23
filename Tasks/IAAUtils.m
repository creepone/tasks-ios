//
//  IAAUtils.m
//  Tasks
//
//  Created by Tomas Vana on 3/11/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAAUtils.h"

@implementation IAAUtils

+ (NSString *)documentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSError *error;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:&error]) {
        DDLogError(@"Error: Create documents folder at %@ failed: %@", basePath, [error localizedDescription]);
    }
    
    return basePath;
}

+ (NSString *)generateUuid
{
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}

@end
