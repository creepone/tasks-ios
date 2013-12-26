//
//  IAANetworkConfiguration.h
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAANetworkConfiguration : NSObject

+ (IAANetworkConfiguration *)sharedConfiguration;

/**
 Reload the settings from the server.
 */
- (void)refresh;

/**
 URL of the endpoint used to initiate the authentication process.
 */
- (NSURL *)authenticationURL;

/**
 URL of the endpoint used to initiate the synchronization process.
 */
- (NSString *)syncURLString;

@end
