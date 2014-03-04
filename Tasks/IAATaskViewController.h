//
//  IAATaskViewController.h
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAATask, IAATaskViewController;

@protocol IAATaskViewControllerDelegate <NSObject>

/**
 Invoked after the task view controller saved (or created) a task.
 */
- (void)taskViewController:(IAATaskViewController *)taskViewController didSaveTask:(IAATask *)task created:(BOOL)created;

@end

@interface IAATaskViewController : UITableViewController

- (id)initWithTask:(IAATask *)task;

@property (nonatomic, weak) id<IAATaskViewControllerDelegate> delegate;

- (void)setCategories:(NSSet *)categories;

@end
