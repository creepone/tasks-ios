//
//  IAAKeyboard.h
//  Tasks
//
//  Created by Tomas Vana on 3/15/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAAKeyboard : NSObject

+ (IAAKeyboard *)sharedKeyboard;

- (BOOL)isShown;
- (CGRect)frame;

@end
