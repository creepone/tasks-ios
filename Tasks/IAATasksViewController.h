//
//  IAATasksViewController.h
//  Tasks
//
//  Created by Tomas Vana on 3/16/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAACategory;

@interface IAATasksViewController : UITableViewController

- (id)initWithCategory:(IAACategory *)category;
- (id)initWithDueTasks;
- (id)initWithDatesBetween:(NSDate *)startDate and:(NSDate *)endDate title:(NSString *)title;

@end
