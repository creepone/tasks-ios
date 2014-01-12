//
//  IAADefaultsManager.m
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAADefaultsManager.h"

NSString *kDataStoreVersion = @"DataStoreVersion";
NSString *kNotificationSoundName = @"NotificationSoundName";

NSString *kNotificationSoundNameNULL = @"OFF";

@implementation IAADefaultsManager

+ (NSInteger)dataStoreVersion {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:kDataStoreVersion];
}

+ (void)setDataStoreVersion:(NSInteger)version {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:version forKey:kDataStoreVersion];
    [userDefaults synchronize];
}

+ (NSString *)notificationSoundName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefaults stringForKey:kNotificationSoundName];
    return [value isEqualToString:kNotificationSoundNameNULL] ? nil : value;
}

+ (void)setNotificationSoundName:(NSString *)soundName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // we should preserve the value "nil" in this case as it actually has a meaning
    if (soundName == nil)
        soundName = kNotificationSoundNameNULL;
    
    [userDefaults setObject:soundName forKey:kNotificationSoundName];
    [userDefaults synchronize];
}

+ (void)registerDefaults {
    NSDictionary *userDefaultsDefaults = @{ kNotificationSoundName: @"pebbles.caf", kDataStoreVersion: @0 };
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
}


@end
