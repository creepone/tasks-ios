//
//  IAASyncBatch.m
//  Tasks
//
//  Created by Tomas Vana on 30/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAASyncBatch.h"
#import "IAAImportBatch.h"
#import "IAADataAccess.h"
#import "IAANetworkConfiguration.h"
#import "IAAIdentityManager.h"
#import "AFNetworking.h"

@interface IAASyncBatch(){
    AFHTTPRequestOperationManager *_requestManager;
    IAADataAccess *_dataAccess;
    IAANetworkConfiguration *_networkConfig;
}

- (NSDictionary *)patchesToSend;
- (NSDictionary *)dataToAcknowledge:(NSDictionary *)syncResponse;

- (BOOL)save;
- (void)merge:(NSDictionary *)response;
- (void)acknowledge:(NSDictionary *)response;

@end

@implementation IAASyncBatch

- (id)init
{
    self = [super init];
    if (self) {
        _requestManager = [AFHTTPRequestOperationManager manager];
        
        _dataAccess = [[IAADataAccess alloc] initWithNewContext:YES];
        _dataAccess.context.undoManager = nil;
        
        _networkConfig = [IAANetworkConfiguration sharedConfiguration];
        [_networkConfig refresh];
    }
    return self;
}

- (void)start
{
    NSString *syncURL = [_networkConfig syncURLString];
    if (syncURL == nil) {
        [self.delegate syncBatch:self completedWithError:nil];
        return;
    }
    
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:syncURL parameters:[self patchesToSend]];
    
    AFHTTPRequestOperation *operation = [_requestManager HTTPRequestOperationWithRequest:request
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"JSON: %@", responseObject);
         
         NSDictionary *result = (NSDictionary *)responseObject;
         if ([result objectForKey:@"error"] != nil) {
             NSError *error = [NSError errorWithDomain:@"SyncFailure" code:100 userInfo:nil];
             [self.delegate syncBatch:self completedWithError:error];
             return;
         }
         
         if (![self save]) return;
         
         [self merge:result];
         [self acknowledge:result];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSInteger statusCode = [operation.response statusCode];
         
         if (statusCode == 403)
             [[IAAIdentityManager sharedManager] resetIdentity];
         
         [self.delegate syncBatch:self completedWithError:error];
     }];
    
    [_requestManager.operationQueue addOperation:operation];
}

- (void)merge:(NSDictionary *)response
{
    IAAImportBatch *importer = [[IAAImportBatch alloc] initWithDataAccess:_dataAccess andData:response];
    
    NSError *error;
    if (![importer importAll:&error])
    {
        [self.delegate syncBatch:self completedWithError:error];
        return;
    }
}

- (void)acknowledge:(NSDictionary *)response
{
    NSString *acknowledgeURL = [_networkConfig acknowledgeURLString];

    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:acknowledgeURL parameters:[self dataToAcknowledge:response]];

    AFHTTPRequestOperation *operation = [_requestManager HTTPRequestOperationWithRequest:request
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSDictionary *result = (NSDictionary *)responseObject;
         if ([result objectForKey:@"error"] != nil) {
             NSError *error = [NSError errorWithDomain:@"SyncFailure" code:101 userInfo:nil];
             [self.delegate syncBatch:self completedWithError:error];
             return;
         }
         
         // we're done at this point
         [self.delegate syncBatch:self completedWithError:nil];

     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [self.delegate syncBatch:self completedWithError:error];
     }];
    
    [_requestManager.operationQueue addOperation:operation];
}

- (NSDictionary *)patchesToSend
{
    NSMutableArray *patches = [NSMutableArray array];
    
    [_dataAccess performForEachPatchToSync:^(IAAPatch *patch) {
        [patches addObject:patch.dictionaryRepresentation];
        patch.state = kIAAPatchStateServer;
    }];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:@{@"patches": patches}];
    
    NSString *token = [[IAAIdentityManager sharedManager] deviceToken];
    if (token != nil)
        [result setObject:token forKey:@"token"];
    
    return result;
}

- (NSDictionary *)dataToAcknowledge:(NSDictionary *)syncResponse
{
    NSArray *syncedIds = [syncResponse objectForKey:@"toAcknowledge"];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:@{@"syncedIds" : syncedIds}];
    
    NSString *lastPatchId = [_dataAccess lastAvailablePatchId];
    if (lastPatchId != nil)
        [result setObject:lastPatchId forKey:@"lastPatchId"];
    
    NSString *token = [[IAAIdentityManager sharedManager] deviceToken];
    if (token != nil)
        [result setObject:token forKey:@"token"];
    
    return result;
}

- (BOOL)save
{
    NSError *error;
    [_dataAccess saveChanges:&error];
    
    if (error != nil) {
        [self.delegate syncBatch:self completedWithError:error];
        return NO;
    }
    else
        return YES;
}

@end
