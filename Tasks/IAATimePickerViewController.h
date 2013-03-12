//
//  IAATimePickerViewController.h
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAATimePickerViewController;

@protocol IAATimePickerViewControllerDelegate <NSObject>

- (void)timePicker:(IAATimePickerViewController *)timePicker selectedTime:(NSDate *)time;

@end


@interface IAATimePickerViewController : UIViewController

- (id)initWithTime:(NSDate *)time;

@property (nonatomic, weak) id<IAATimePickerViewControllerDelegate> delegate;

@end
