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
#import "Reachability.h"

@implementation IAASyncManager

+ (BOOL)isOnline
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return networkStatus == NotReachable ? NO : YES;
}

+ (void)syncAll
{
    NSLog(@"patches: %@", [self jsonToSend]);
}

+ (NSString *)jsonToSend
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
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:&error];
    
    if (![IAAErrorManager checkError:error])
        return nil;
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
