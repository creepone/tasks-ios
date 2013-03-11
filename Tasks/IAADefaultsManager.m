//
//  IAADefaultsManager.m
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAADefaultsManager.h"

NSString *kDataStoreVersion = @"DataStoreVersion";

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

@end
