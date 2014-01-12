//
//  IAANotificationSounds.h
//  Tasks
//
//  Created by Tomas Vana on 12/01/14.
//  Copyright (c) 2014 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAANotificationSounds : NSObject

+ (IAANotificationSounds *)sharedSounds;

- (NSString *)labelForSound:(NSString *)sound;
- (NSArray *)allSounds;
- (void)playSound:(NSString *)soundName;

@end
