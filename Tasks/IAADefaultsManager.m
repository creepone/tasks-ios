//
//  IAADefaultsManager.m
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAADefaultsManager.h"

@implementation IAADefaultsManager

static NSString *kUsername = @"Username";

+ (NSString *)username {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:kUsername];
}

+ (void)setUsername:(NSString *)username {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:username forKey:kUsername];
    [userDefaults synchronize];
}

@end
