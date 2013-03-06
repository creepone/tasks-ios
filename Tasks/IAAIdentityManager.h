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

/**
 Notification sent when the process of acquiring the identity was successfuly completed.
 */
extern NSString * const IAAIdentityManagerAcquiredIdentityNotification;

@interface IAAIdentityManager : NSObject

+ (IAAIdentityManager *)sharedManager;

/**
 If available, the username associated with the account on the server.
 */
@property (nonatomic, strong) NSString *username;

/**
 Token of the device associated with the account on the server. Used for authentication.
 */
@property (nonatomic, strong) NSString *deviceToken;

/**
 If there is no identity yet, this method initiates the process of acquiring one.
 */
- (void)acquireIdentity;

@end
