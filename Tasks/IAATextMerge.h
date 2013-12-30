//
//  IAATextMerge.h
//  Tasks
//
//  Created by Tomas Vana on 30/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAATextMerge : NSObject

+ (NSString *)merge:(NSString *)oldVersion current:(NSString *)currentVersion new:(NSString *)newVersion;

@end
