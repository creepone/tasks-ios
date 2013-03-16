//
//  IAANotificationManager.m
//  Tasks
//
//  Created by Tomas Vana on 3/16/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAANotificationManager.h"
#import "IAADataAccess.h"

@interface IAANotificationManager()
@end

@implementation IAANotificationManager

+ (IAANotificationManager *)sharedManager
{
    static dispatch_once_t once;
    static IAANotificationManager *sharedManager;
    dispatch_once(&once, ^ { sharedManager = [[self alloc] init]; });
    return sharedManager;
}

- (void)rescheduleAll
{
    IAADataAccess *dataAccess = [IAADataAccess sharedDataAccess];
    UIApplication *application = [UIApplication sharedApplication];
    
    [application cancelAllLocalNotifications];
    
    __block NSInteger current = 0;
    __block NSInteger future = 0;
    
    [dataAccess performForEachSchedulableTask:^(IAATask *task)
    {
        if (task.reminderDate == nil)
            return;

        future++;
        
        if ([task.reminderDate compare:[NSDate date]] == NSOrderedAscending) {
            current++;
            return;
        }
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = task.reminderDate;
        notification.applicationIconBadgeNumber = future;
        
        if (task.reminderImportant) {
            notification.alertBody = task.name;
            notification.alertAction = @"Show";
            notification.soundName = UILocalNotificationDefaultSoundName;
        }
        
        [application scheduleLocalNotification:notification];
    }];
    
    [application setApplicationIconBadgeNumber:current];
}

@end
