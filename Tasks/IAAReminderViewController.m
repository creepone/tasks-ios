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
#import "IAATaskChanges.h"
#import "IAADataAccess.h"
#import "IAAColor.h"

@interface IAAReminderViewController () <IAADatePickerViewControllerDelegate, IAATimePickerViewControllerDelegate> {
    IAATaskChanges *_taskChanges;
    UISwitch *_switchImportant;
}

- (void)setupNavigationBarItems;

@end

@implementation IAAReminderViewController

- (id)initWithTaskChanges:(IAATaskChanges *)taskChanges
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _taskChanges = taskChanges;
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
    _taskChanges.reminderImportant = NO;
    _taskChanges.reminderDate = nil;
    [self.tableView reloadData];
}

- (void)changedSwitchValue
{
    _taskChanges.reminderImportant = _switchImportant.on;
}

- (void)datePicker:(IAADatePickerViewController *)datePicker selectedDate:(NSDate *)date
{
    IAADateCalculator *dateCalculator = [IAADateCalculator sharedCalculator];
    
    if (_taskChanges.reminderDate == nil)
        _taskChanges.reminderDate = [dateCalculator today];
    
    if (date == nil)
        date = [dateCalculator today];
    
    _taskChanges.reminderDate = [dateCalculator dateWithDate:date timePart:_taskChanges.reminderDate];
    [self.tableView reloadData];
}

- (void)timePicker:(IAATimePickerViewController *)timePicker selectedTime:(NSDate *)time
{
    IAADateCalculator *dateCalculator = [IAADateCalculator sharedCalculator];

    if (_taskChanges.reminderDate == nil)
        _taskChanges.reminderDate = [dateCalculator today];
    
    if (time == nil)
        time = [dateCalculator today];
    
    _taskChanges.reminderDate = [dateCalculator dateWithDate:_taskChanges.reminderDate timePart:time];
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
            _switchImportant.on = _taskChanges.reminderImportant;
            [_switchImportant addTarget:self action:@selector(changedSwitchValue) forControlEvents:UIControlEventValueChanged];
        }
        else {
            [_switchImportant setOn:_taskChanges.reminderImportant animated:YES];
        }
        
        cell.accessoryView = _switchImportant;
        cell.textLabel.text = @"Important";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Date";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (_taskChanges.reminderDate != nil)
        {
            cell.detailTextLabel.text = [[IAADateFormatter sharedFormatter] shortDateStringFromDate:_taskChanges.reminderDate];
        }
        else
            cell.detailTextLabel.text = @"";
    }
    
    if (indexPath.row == 2)
    {
        cell.textLabel.text = @"Time";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (_taskChanges.reminderDate != nil)
        {
            cell.detailTextLabel.text = [[IAADateFormatter sharedFormatter] shortTimeStringFromDate:_taskChanges.reminderDate];            
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
        IAADatePickerViewController *dpvc = [[IAADatePickerViewController alloc] initWithDate:_taskChanges.reminderDate];
        dpvc.delegate = self;
        [self.navigationController pushViewController:dpvc animated:YES];
    }
    
    if (indexPath.row == 2)
    {
        NSDate *time = _taskChanges.reminderDate == nil ? [dateCalculator today] : _taskChanges.reminderDate;
        
        IAATimePickerViewController *tpvc = [[IAATimePickerViewController alloc] initWithTime:time];
        tpvc.delegate = self;
        [self.navigationController pushViewController:tpvc animated:YES];
    }
}

@end
