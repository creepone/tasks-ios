//
//  IAAApnTokenManager.m
//  Tasks
//
//  Created by Tomas Vana on 23/01/14.
//  Copyright (c) 2014 iOS Apps Austria. All rights reserved.
//

#import "IAAApnTokenManager.h"
#import "IAAIdentityManager.h"
#import "IAANetworkConfiguration.h"
#import "AFNetworking.h"
#import "IAAErrorManager.h"


@implementation IAAApnTokenManager

+ (void)sendToken:(NSString *)apnToken
{
    IAANetworkConfiguration *networkConfig = [IAANetworkConfiguration sharedConfiguration];
    [networkConfig refresh];
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];

    NSString *tokenURL = [networkConfig apnTokenURLString];
    if (tokenURL == nil)
        return;
    
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:tokenURL parameters:[self tokensToSend:apnToken]];
    
    AFHTTPRequestOperation *operation = [requestManager HTTPRequestOperationWithRequest:request
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             
             NSDictionary *result = (NSDictionary *)responseObject;
             if ([result objectForKey:@"error"] != nil) {
                 NSError *error = [NSError errorWithDomain:@"ApnTokenFailure" code:101 userInfo:nil];
                 [IAAErrorManager checkError:error];
                 return;
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [IAAErrorManager checkError:error];
         }];
    
    [requestManager.operationQueue addOperation:operation];
    [requestManager.operationQueue waitUntilAllOperationsAreFinished];
}

+ (NSDictionary *)tokensToSend:(NSString *)apnToken
{
    NSMutableDictionary *result = [@{@"apnToken": apnToken} mutableCopy];
    
    NSString *token = [[IAAIdentityManager sharedManager] deviceToken];
    if (token != nil)
        [result setObject:token forKey:@"token"];
    
    return result;
}

@end
