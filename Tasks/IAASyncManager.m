//
//  IAASyncManager.m
//  Tasks
//
//  Created by Tomas Vana on 25/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAASyncManager.h"
#import "IAASyncBatch.h"
#import "Reachability.h"
#import "IAAErrorManager.h"
#import "IAANotificationManager.h"
#import "IAAIdentityManager.h"

NSString * const IAASyncManagerFinishedSync = @"IAASyncManagerFinishedSync";

@interface IAASyncManager() <IAASyncBatchDelegate> {
    IAASyncBatch *_batch;
    BOOL _pending;
}

- (void)syncAll;

@end

@implementation IAASyncManager

+ (BOOL)isOnline
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return networkStatus == NotReachable ? NO : YES;
}

+ (IAASyncManager *)sharedManager
{
    static dispatch_once_t once;
    static IAASyncManager *sharedManager;
    dispatch_once(&once, ^ { sharedManager = [[self alloc] init]; });
    return sharedManager;
}


- (BOOL)isActive
{
    return _batch != nil || _pending;
}

- (void)enqueueSync
{
    // we can't sync if we're offline or have no identity
    if (![IAASyncManager isOnline] || [[IAAIdentityManager sharedManager] deviceToken] == nil)
        return;
    
    _pending = YES;
    [self peek];
}

- (void)peek
{
    if (_pending && _batch == nil) {
        _pending = NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self performSelectorInBackground:@selector(syncAll) withObject:self];
    }
}

- (void)syncAll
{
    @try {
        _batch = [[IAASyncBatch alloc] init];
        [_batch setDelegate:self];
        [_batch start];
        
        // wait until done
        while (_batch != nil)
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:IAASyncManagerFinishedSync object:self];
            [[IAANotificationManager sharedManager] rescheduleAll];
            [self peek];
        });
    }
    @catch (NSException *exception) {
        // ignore - we don't want to crash the whole app when something goes wrong here
    }
}

- (void)syncBatch:(IAASyncBatch *)batch completedWithError:(NSError *)error
{
    [batch setDelegate:nil];
    _batch = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [IAAErrorManager checkError:error];
    });
}

@end
