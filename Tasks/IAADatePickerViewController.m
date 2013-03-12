//
//  IAADatePickerViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <TapkuLibrary/TapkuLibrary.h>

#import "IAADatePickerViewController.h"
#import "IAADateCalculator.h"
#import "IAAColor.h"

@interface IAADatePickerViewController () <TKCalendarMonthViewDelegate> {
    NSDate *_date;
    TKCalendarMonthView *_calendar;
}

@end

@implementation IAADatePickerViewController

- (id)initWithDate:(NSDate *)date
{
    self = [super init];
    if (self) {
        self.title = @"Date";
        _date = date;
        _calendar = [[TKCalendarMonthView alloc] initWithSundayAsFirst:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [IAAColor tableViewBackgroundColor];

    if (_date != nil)
        [_calendar selectDate:[[IAADateCalculator sharedCalculator] gmtDateWithLocalDate:_date]];
    
    [_calendar setDelegate:self];
    [self.view addSubview:_calendar];
    
    UIButton *buttonSubmit = [[UIButton alloc] initWithFrame:CGRectMake(5, 320, 310, 44)];
    
    [buttonSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonSubmit setTitle:@"Select" forState:UIControlStateNormal];
    [[buttonSubmit titleLabel] setFont:[UIFont boldSystemFontOfSize:17.0]];
    
    [buttonSubmit setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [buttonSubmit setBackgroundImage:[UIImage imageNamed:@"button_pressed"] forState:UIControlStateHighlighted];
    
    [buttonSubmit addTarget:self action:@selector(tappedSubmit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonSubmit];
}

- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date
{    
    _date = [[IAADateCalculator sharedCalculator] localDateWithGmtDate:date];
}

- (void)tappedSubmit
{
    if (self.delegate != nil)
        [self.delegate datePicker:self selectedDate:_date];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [_calendar setDelegate:nil];
}

@end
