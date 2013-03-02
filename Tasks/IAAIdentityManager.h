//
//  IAAIdentityManager.h
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    IAAOpenIDProviderGeneric,
	IAAOpenIDProviderGoogle,
    IAAOpenIDProviderYahoo,
    IAAOpenIDProviderAol,
    IAAOpenIDProviderMyOpenID
} IAAOpenIDProvider;

@interface IAAIdentityManager : NSObject

+ (IAAIdentityManager *)sharedManager;

/**
 If available, the username associated with the account on the server.
 */
@property (nonatomic, strong) NSString *username;

/**
 ID of the device associated with the account on the server. Used as an authentication token.
 */
@property (nonatomic, strong) NSString *deviceId;

/**
 If there is no identity yet, this method initiates the process of acquiring one.
 */
- (void)acquireIdentity;

@end
