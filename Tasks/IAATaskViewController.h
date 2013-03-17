//
//  IAATaskViewController.h
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAATask;

@interface IAATaskViewController : UITableViewController

- (id)initWithTask:(IAATask *)task;

- (void)setCategories:(NSSet *)categories;

@end
