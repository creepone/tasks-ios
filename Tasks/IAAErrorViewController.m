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
    
    if (_error.userInfo != nil)
        self.textViewDetails.text = [NSString stringWithFormat:@"%@ %@", [_error localizedDescription], [_error.userInfo description]];
    else
        self.textViewDetails.text = [_error localizedDescription];}

- (IBAction)tappedDismiss:(id)sender
{
    if (self.callbackDismiss != nil)
        self.callbackDismiss();
}

@end
