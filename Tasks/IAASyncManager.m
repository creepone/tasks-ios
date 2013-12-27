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

- (NSDictionary *)patchesToSend;
- (void)markAllSynced;

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
    IAANetworkConfiguration *networkConfig = [IAANetworkConfiguration sharedConfiguration];
    [networkConfig refresh];
    
    NSString *syncURL = [networkConfig syncURLString];
    if (syncURL == nil)
        return;
    
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:syncURL parameters:[self patchesToSend]];
    
    AFHTTPRequestOperation *operation = [_requestManager HTTPRequestOperationWithRequest:request
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *result = (NSDictionary *)responseObject;
        if ([result objectForKey:@"error"] != nil)
            return;
        
        [self markAllSynced];
        
        // todo: merge in the response
        
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
    
    NSString *token = [[IAAIdentityManager sharedManager] deviceToken];
    if (token != nil)
        [result setObject:token forKey:@"token"];
    
    return result;
}

- (void)markAllSynced
{
    IAADataAccess *dataAccess = [IAADataAccess sharedDataAccess];
    
    [dataAccess performForEachPatchToSync:^(IAAPatch *patch) {
        patch.state = kIAAPatchStateServer;
    }];
    
    NSError *error;
    [dataAccess saveChanges:&error];
    [IAAErrorManager checkError:error];
}

@end
