//
//  IAAApnTokenManager.h
//  Tasks
//
//  Created by Tomas Vana on 23/01/14.
//  Copyright (c) 2014 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAAApnTokenManager : NSObject

+ (void)sendToken:(NSString *)apnToken;

@end
