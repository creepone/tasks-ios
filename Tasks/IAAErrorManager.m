//
//  IAAErrorManager.m
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAAErrorManager.h"
#import "IAAErrorViewController.h"
#import "IAALog.h"

@implementation IAAErrorManager

+ (BOOL)checkError:(NSError *)error
{
    if (error == nil)
        return YES;
    
    DDLogError(@"%@", [error localizedDescription]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    
    dispatch_async(dispatch_get_main_queue(),^{
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        
        __block IAAErrorViewController *evc = [[IAAErrorViewController alloc] initWithError:error];
        
        evc.view.frame = [[UIScreen mainScreen] applicationFrame];
        evc.callbackDismiss = ^{
            [UIView animateWithDuration:1.0 animations:^{
                evc.view.alpha = 0.0;
            }
            completion:^(BOOL finished) {
                [evc.view removeFromSuperview];
                evc = nil;
            }];
        };
        
        [window addSubview:evc.view];
        evc.view.alpha = 0.0;
        
        [UIView animateWithDuration:1.0 animations:^{
            evc.view.alpha = 1.0;
        }];
    });
    
#pragma clang diagnostic pop
    
    return NO;
}

@end
