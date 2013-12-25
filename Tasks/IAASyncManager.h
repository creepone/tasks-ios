//
//  IAASyncManager.h
//  Tasks
//
//  Created by Tomas Vana on 25/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAASyncManager : NSObject

+ (BOOL)isOnline;

+ (void)syncAll;

@end
