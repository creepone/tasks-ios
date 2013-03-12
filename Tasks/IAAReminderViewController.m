//
//  IAAReminderViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAAReminderViewController.h"
#import "IAADatePickerViewController.h"
#import "IAATimePickerViewController.h"
#import "IAADateFormatter.h"
#import "IAADateCalculator.h"
#import "IAADataAccess.h"
#import "IAAColor.h"

@interface IAAReminderViewController () <IAADatePickerViewControllerDelegate, IAATimePickerViewControllerDelegate> {
    IAATask *_task;
    UISwitch *_switchImportant;
}

- (void)setupNavigationBarItems;

@end

@implementation IAAReminderViewController

- (id)initWithTask:(IAATask *)task
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _task = task;
        self.title = @"Reminder";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavigationBarItems];
    
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[IAAColor tableViewBackgroundColor]];
}

- (void)setupNavigationBarItems
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(tappedClear)];
}

- (void)tappedClear
{
    _task.reminderImportant = NO;
    _task.reminderDate = nil;
    [self.tableView reloadData];
}

- (void)changedSwitchValue
{
    _task.reminderImportant = _switchImportant.on;
}

- (void)datePicker:(IAADatePickerViewController *)datePicker selectedDate:(NSDate *)date
{
    IAADateCalculator *dateCalculator = [IAADateCalculator sharedCalculator];
    
    if (_task.reminderDate == nil)
        _task.reminderDate = [dateCalculator today];
    
    _task.reminderDate = [dateCalculator dateWithDate:date timePart:_task.reminderDate];
    [self.tableView reloadData];
}

- (void)timePicker:(IAATimePickerViewController *)timePicker selectedTime:(NSDate *)time
{
    IAADateCalculator *dateCalculator = [IAADateCalculator sharedCalculator];

    if (_task.reminderDate == nil)
        _task.reminderDate = [dateCalculator today];
    
    _task.reminderDate = [dateCalculator dateWithDate:_task.reminderDate timePart:time];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell = cell == nil ? [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIdentifier] : cell;
    
    if (indexPath.row == 0)
    {
        if (_switchImportant == nil) {
            _switchImportant = [[UISwitch alloc] init];
            _switchImportant.on = _task.reminderImportant;
            [_switchImportant addTarget:self action:@selector(changedSwitchValue) forControlEvents:UIControlEventValueChanged];
        }
        else {
            [_switchImportant setOn:_task.reminderImportant animated:YES];
        }
        
        cell.accessoryView = _switchImportant;
        cell.textLabel.text = @"Important";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Date";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (_task.reminderDate != nil)
        {
            cell.detailTextLabel.text = [[IAADateFormatter sharedFormatter] shortDateStringFromDate:_task.reminderDate];
        }
        else
            cell.detailTextLabel.text = @"";
    }
    
    if (indexPath.row == 2)
    {
        cell.textLabel.text = @"Time";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (_task.reminderDate != nil)
        {
            cell.detailTextLabel.text = [[IAADateFormatter sharedFormatter] shortTimeStringFromDate:_task.reminderDate];            
        }
        else
            cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    IAADateCalculator *dateCalculator = [IAADateCalculator sharedCalculator];    
    
    if (indexPath.row == 1)
    {
        IAADatePickerViewController *dpvc = [[IAADatePickerViewController alloc] initWithDate:_task.reminderDate];
        dpvc.delegate = self;
        [self.navigationController pushViewController:dpvc animated:YES];
    }
    
    if (indexPath.row == 2)
    {
        NSDate *time = _task.reminderDate == nil ? [dateCalculator today] : _task.reminderDate;
        
        IAATimePickerViewController *tpvc = [[IAATimePickerViewController alloc] initWithTime:time];
        tpvc.delegate = self;
        [self.navigationController pushViewController:tpvc animated:YES];
    }
}

@end
