//
//  IAAOpenidSelectViewController.h
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAAIdentityManager.h"

@interface IAAOpenidSelectViewController : UITableViewController

@property (nonatomic, copy) void (^callbackSelect)(IAAOpenIDProvider);

@end
