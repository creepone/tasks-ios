//
//  IAAUtils.h
//  Tasks
//
//  Created by Tomas Vana on 3/11/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAAUtils : NSObject

+ (NSString *)documentDirectoryPath;

+ (NSString *)generateUuid;

+ (BOOL)isNilOrNull:(NSObject *)object;

@end
