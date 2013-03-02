//
//  IAAOpenidAccountViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAAOpenidAccountViewController.h"
#import "NSString+Extensions.h"

@interface IAAOpenidAccountViewController() <UITextFieldDelegate> {
    IAAOpenIDProvider _provider;
}

- (void)setupLogo;

@end

@implementation IAAOpenidAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Account";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLogo];
    [self.textFieldAccount becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text iaa_isEmptyOrWhitespace])
        return NO;
    
    if (self.callbackDone)
        self.callbackDone(textField.text);
    return YES;
}

- (void)setupLogo
{
    switch (_provider) {
        case IAAOpenIDProviderAol:
            self.imageViewLogo.image = [UIImage imageNamed:@"openid-aol.png"];
            break;
        case IAAOpenIDProviderMyOpenID:
            self.imageViewLogo.image = [UIImage imageNamed:@"openid-myopenid.png"];
            break;
        default:
            self.imageViewLogo.image = [UIImage imageNamed:@"openid.png"];
            break;
    }
}

- (void)setProvider:(IAAOpenIDProvider)provider
{
    _provider = provider;
    [self setupLogo];
}

@end
