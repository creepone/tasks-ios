//
//  IAASyncManager.m
//  Tasks
//
//  Created by Tomas Vana on 25/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAASyncManager.h"
#import "IAADataAccess.h"
#import "IAAErrorManager.h"
#import "IAAIdentityManager.h"
#import "IAANetworkConfiguration.h"
#import "Reachability.h"
#import "AFNetworking.h"

@interface IAASyncManager(){
    AFHTTPRequestOperationManager *_requestManager;
}

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

- (id)init
{
    self = [super init];
    if (self) {
        _requestManager = [AFHTTPRequestOperationManager manager];
    }
    return self;
}

- (void)syncAll
{
    NSString *syncURL = [[IAANetworkConfiguration sharedConfiguration] syncURLString];
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:syncURL parameters:[self patchesToSend]];
    
    AFHTTPRequestOperation *operation = [_requestManager HTTPRequestOperationWithRequest:request
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [IAAErrorManager checkError:error];
    }];
    
    [_requestManager.operationQueue addOperation:operation];
}

- (NSDictionary *)patchesToSend
{
    IAADataAccess *dataAccess = [IAADataAccess sharedDataAccess];
    NSMutableArray *patches = [NSMutableArray array];
    
    [dataAccess performForEachPatchToSync:^(IAAPatch *patch) {
        [patches addObject:patch.dictionaryRepresentation];
    }];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:@{@"patches": patches}];
    
    NSString *lastPatchId = [dataAccess lastAvailablePatchId];
    if (lastPatchId != nil)
        [result setObject:lastPatchId forKey:@"lastPatchId"];
    
    NSString *token = [[IAAIdentityManager sharedManager] deviceToken];
    if (token != nil)
        [result setObject:token forKey:@"token"];
    
    return result;
}

@end
