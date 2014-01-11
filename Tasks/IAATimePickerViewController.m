//
//  IAATimePickerViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAATimePickerViewController.h"
#import "IAAColor.h"

@interface IAATimePickerViewController () {
    NSDate *_time;
    UIDatePicker *_datePicker;
}

@end

@implementation IAATimePickerViewController

- (id)initWithTime:(NSDate *)time
{
    self = [super init];
    if (self) {
        self.title = @"Time";
        _time = time;
        _datePicker = [[UIDatePicker alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [IAAColor tableViewBackgroundColor];
    
    [_datePicker setDatePickerMode:UIDatePickerModeTime];
    [_datePicker setDate:_time];
    [_datePicker addTarget:self action:@selector(changedTime) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_datePicker];
    
    UIButton *buttonSubmit = [[UIButton alloc] initWithFrame:CGRectMake(5, 320, 310, 44)];
    
    [buttonSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonSubmit setTitle:@"Select" forState:UIControlStateNormal];
    [[buttonSubmit titleLabel] setFont:[UIFont boldSystemFontOfSize:17.0]];
    
    [buttonSubmit setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [buttonSubmit setBackgroundImage:[UIImage imageNamed:@"button_pressed"] forState:UIControlStateHighlighted];
    
    [buttonSubmit addTarget:self action:@selector(tappedSubmit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonSubmit];
}

- (void)tappedSubmit
{
    if (self.delegate != nil)
        [self.delegate timePicker:self selectedTime:_time];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changedTime
{
    _time = _datePicker.date;
}

@end
