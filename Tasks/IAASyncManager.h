//
//  IAASyncManager.h
//  Tasks
//
//  Created by Tomas Vana on 25/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Notification sent when the sync has been finished in the background.
 */
extern NSString * const IAASyncManagerFinishedSync;


@interface IAASyncManager : NSObject

+ (IAASyncManager *)sharedManager;
+ (BOOL)isOnline;

- (void)enqueueSync;

@end
