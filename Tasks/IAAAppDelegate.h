//
//  IAAAppDelegate.h
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAAMainViewController, IAACoreDataStack;

@interface IAAAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) IAAMainViewController *mainViewController;

@property (nonatomic) IAACoreDataStack *coreDataStack;

@end
