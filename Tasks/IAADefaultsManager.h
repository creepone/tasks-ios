//
//  IAADefaultsManager.h
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAADefaultsManager : NSObject

/**
 Version of the data store used to ensure that it is compatible with the model and was
 initialized with a default set of objects
 */
+ (NSInteger)dataStoreVersion;
+ (void)setDataStoreVersion:(NSInteger)version;

+ (NSString *)notificationSoundName;
+ (void)setNotificationSoundName:(NSString *)soundName;

+ (void)registerDefaults;

@end
