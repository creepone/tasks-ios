//
//  IAANotificationSounds.m
//  Tasks
//
//  Created by Tomas Vana on 12/01/14.
//  Copyright (c) 2014 iOS Apps Austria. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "IAANotificationSounds.h"

NSString *kSoundOffLabel = @"Off";

@interface IAANotificationSounds() {
    NSDictionary *_sounds;
}

@end

void playSoundFinished (SystemSoundID sound, void *data) {
    AudioServicesRemoveSystemSoundCompletion(sound);
    AudioServicesDisposeSystemSoundID(sound);
}

@implementation IAANotificationSounds

- (id)init {
    self = [super init];
    if (self) {
        _sounds = @{
            @"alert.caf": @"Alert",
            @"best.caf": @"Best",
            @"beep.caf": @"Beep",
            @"message1.caf": @"Message 1",
            @"message2.caf": @"Message 2",
            @"pebbles.caf": @"Pebbles",
            @"text.caf": @"Text",
            @"viber.caf": @"Viber",
            @"wind_chime.caf": @"Wind Chime"
        };
    }
    return self;
}

+ (IAANotificationSounds *)sharedSounds
{
    static dispatch_once_t once;
    static IAANotificationSounds *sharedSounds;
    dispatch_once(&once, ^ { sharedSounds = [[self alloc] init]; });
    return sharedSounds;
}

- (NSString *)labelForSound:(NSString *)sound
{
    if (sound == nil)
        return kSoundOffLabel;
    else
        return _sounds[sound];
}

- (NSArray *)allSounds
{
    return [[_sounds allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)playSound:(NSString *)soundName
{
    if (soundName == nil)
        return;
    
    soundName = [[NSBundle mainBundle] pathForResource:[soundName componentsSeparatedByString:@"."][0] ofType:@"caf"];
    
    CFURLRef soundURL = (__bridge CFURLRef)[NSURL fileURLWithPath:soundName];
    
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID(soundURL, &sound);
    AudioServicesAddSystemSoundCompletion(sound, nil, nil, playSoundFinished, nil);
    AudioServicesPlaySystemSound(sound);
}

@end
