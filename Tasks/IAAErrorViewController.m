//
//  IAAErrorViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAAErrorViewController.h"

@interface IAAErrorViewController() {
    NSError *_error;
}

@end

@implementation IAAErrorViewController

- (id)initWithError:(NSError *)error
{
    self = [super init];
    if (self) {
        _error = error;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textViewDetails.text = [_error localizedDescription];
}

- (IBAction)tappedDismiss:(id)sender
{
    if (self.callbackDismiss != nil)
        self.callbackDismiss();
}

@end
