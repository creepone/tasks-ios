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
static NSString *kAcknowledgeURL = @"AcknowledgeURL";
static NSString *kApnTokenURL = @"ApnToken";


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
    _settings = [NSDictionary dictionaryWithContentsOfURL:self.configURL];
}

- (NSURL *)configURL
{
#ifdef DEBUG
    NSURL *url = [NSURL URLWithString:@"http://192.168.0.10:8081/ios/config.local.plist"];
#else
    NSURL *url = [NSURL URLWithString:@"http://tasks.iosapps.at/ios/config.plist"];
#endif
    
    return url;
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

- (NSString *)acknowledgeURLString
{
    return [_settings valueForKey:kAcknowledgeURL];
}

- (NSString *)apnTokenURLString
{
    return [_settings valueForKey:kApnTokenURL];
}

@end
