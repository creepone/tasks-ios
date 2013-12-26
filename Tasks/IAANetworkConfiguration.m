//
//  IAANetworkConfiguration.m
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAANetworkConfiguration.h"
#import "IAAErrorManager.h"

@interface IAANetworkConfiguration() {
    NSDictionary *_settings;
}

@end

@implementation IAANetworkConfiguration

static NSString *kAuthenticationURL = @"AuthenticationURL";
static NSString *kSyncURL = @"SyncURL";

- (id)init
{
    self = [super init];
    if (self) {
        [self refresh];
    }
    return self;
}

+ (IAANetworkConfiguration *)sharedConfiguration
{
    static dispatch_once_t once;
    static IAANetworkConfiguration *sharedConfiguration;
    dispatch_once(&once, ^ { sharedConfiguration = [[self alloc] init]; });
    return sharedConfiguration;
}

- (void)refresh
{
    //NSURL *url = [NSURL URLWithString:@"http://192.168.0.10:8081/ios/config.local.plist"];
    NSURL *url = [NSURL URLWithString:@"http://tasks.iosapps.at/ios/config.plist"];
    _settings = [NSDictionary dictionaryWithContentsOfURL:url];
}

- (NSURL *)authenticationURL
{
    NSString *value = [_settings valueForKey:kAuthenticationURL];
    return (value != nil) ? [NSURL URLWithString:value] : nil;
}

- (NSString *)syncURLString
{
    return [_settings valueForKey:kSyncURL];
}

@end
