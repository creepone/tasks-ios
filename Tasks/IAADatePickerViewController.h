//
//  IAADatePickerViewController.h
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAADatePickerViewController;

@protocol IAADatePickerViewControllerDelegate <NSObject>

- (void)datePicker:(IAADatePickerViewController *)datePicker selectedDate:(NSDate *)date;

@end

@interface IAADatePickerViewController : UIViewController

- (id)initWithDate:(NSDate *)date;

@property (nonatomic, weak) id<IAADatePickerViewControllerDelegate> delegate;

@end
