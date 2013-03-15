//
//  NSObject+PWObject.h
//  Tasks
//
//  Created by Tomas Vana on 3/15/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSObject(Extensions)

- (void)iaa_performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end