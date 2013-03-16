//
//  IAANotificationManager.h
//  Tasks
//
//  Created by Tomas Vana on 3/16/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAANotificationManager : NSObject

+ (IAANotificationManager *)sharedManager;

- (void)rescheduleAll;

@end
