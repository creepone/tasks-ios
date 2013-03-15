//
//  IAAKeyboard.m
//  Tasks
//
//  Created by Tomas Vana on 3/15/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAAKeyboard.h"

@interface IAAKeyboard() {
    BOOL _isShown;
    CGRect _frame;
}

@end

@implementation IAAKeyboard

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    }
    return self;
}

+ (IAAKeyboard *)sharedKeyboard
{
    static dispatch_once_t once;
    static IAAKeyboard *sharedKeyboard;
    dispatch_once(&once, ^ { sharedKeyboard = [[self alloc] init]; });
    return sharedKeyboard;
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&_frame];
    _isShown = YES;
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    _isShown = NO;
}

- (BOOL)isShown
{
    return _isShown;
}

- (CGRect)frame
{
    return _frame;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
