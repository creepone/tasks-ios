//
//  IAAOpenidAccountViewController.h
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAAIdentityManager.h"

@interface IAAOpenidAccountViewController : UIViewController

@property (nonatomic) IAAOpenIDProvider provider;
@property (nonatomic, copy) void (^callbackDone)(NSString *);

@property (strong, nonatomic) IBOutlet UITextField *textFieldAccount;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewLogo;

@end
