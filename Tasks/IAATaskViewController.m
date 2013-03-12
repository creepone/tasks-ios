//
//  IAATaskViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAATaskViewController.h"
#import "IAADataAccess.h"
#import "IAADateFormatter.h"
#import "IAAColor.h"
#import "IAATextFieldCell.h"
#import "IAAReminderViewController.h"
#import "NSString+Extensions.h"

@interface IAATaskViewController () {
    IAATask *_task;
    
    NSString *_text;
}

- (BOOL)newMode;
- (void)setupNavigationBarItems;

@end

@implementation IAATaskViewController

- (id)initWithTask:(IAATask *)task
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _task = task;
        self.title = self.newMode ? @"New Task" : @"Task Details";
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}

- (void)setupNavigationBarItems
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(tappedCancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(tappedSave)];
}

- (void)tappedSave
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)tappedCancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)newMode
{
    return [[_task objectID] isTemporaryID];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    
    switch (indexPath.row)
    {
        case 0:
        {
            cellIdentifier = @"TextFieldCell";
            IAATextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            cell = cell == nil ? [[IAATextFieldCell alloc] initWithReuseIdentifier:cellIdentifier] : cell;
            
            cell.textField.placeholder = @"Title";
            cell.textField.text = _task.name;
            
            if (self.newMode)
                [cell.textField becomeFirstResponder];
            
            return cell;
        }
        case 1:
        {
            cellIdentifier = @"ReminderCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            cell = cell == nil ? [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] : cell;
            
            if (_task.reminderDate == nil)
            {
                cell.textLabel.text = @"Reminder";
                cell.textLabel.textColor = [UIColor lightGrayColor];
            }
            else
            {
                cell.textLabel.text = [[IAADateFormatter sharedFormatter] shortDateTimeStringFromDate:_task.reminderDate];
                cell.textLabel.textColor = _task.reminderImportant ? [UIColor blueColor] : [UIColor blackColor];
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        case 2:
        {
            cellIdentifier = @"CategoriesCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            cell = cell == nil ? [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] : cell;
            
            if ([_task.categories count] == 0)
            {
                cell.textLabel.text = @"Categories";
                cell.textLabel.textColor = [UIColor lightGrayColor];
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        case 3:
        {
            cellIdentifier = @"NotesCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            cell = cell == nil ? [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] : cell;
            
            if (_task.notes == nil || [_task.notes iaa_isEmptyOrWhitespace])
            {
                cell.textLabel.text = @"Notes";
                cell.textLabel.textColor = [UIColor lightGrayColor];
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row)
    {
        case 1:
        {
            IAAReminderViewController *rvc = [[IAAReminderViewController alloc] initWithTask:_task];
            [self.navigationController pushViewController:rvc animated:YES];
            break;
        }
    }
}

@end
