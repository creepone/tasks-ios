//
//  IAATaskViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAATaskViewController.h"
#import "IAADataAccess.h"
#import "IAATaskChanges.h"
#import "IAADateFormatter.h"
#import "IAAColor.h"
#import "IAAErrorManager.h"
#import "IAATextFieldCell.h"
#import "IAAReminderViewController.h"
#import "IAANotesViewController.h"
#import "IAACategoriesViewController.h"
#import "NSString+Extensions.h"
#import "NSArray+Extensions.h"
#import "IAALog.h"

#define kTitleTextField 42
#define kMaxLabelHeight 189

@interface IAATaskViewController () <IAANotesViewControllerDelegate, IAACategoriesViewControllerDelegate> {
    IAATask *_task;
    IAATaskChanges *_taskChanges;
}

- (BOOL)newMode;
- (void)setupNavigationBarItems;
- (NSString *)categoriesText;

@end

@implementation IAATaskViewController

- (id)initWithTask:(IAATask *)task
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _task = task;
        _taskChanges = [[IAATaskChanges alloc] initWithTask:_task];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UITextField *textField = (UITextField *)[self.tableView viewWithTag:kTitleTextField];
    [textField resignFirstResponder];
}

- (void)setupNavigationBarItems
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(tappedCancel)];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(tappedSave)];
    
    BOOL isEmptyName = _taskChanges.name == nil || [_taskChanges.name iaa_isEmptyOrWhitespace];
    [saveButton setEnabled:!isEmptyName];
    
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)tappedSave
{
    // todo: we need much more (and a different) logic here -> creating patch, triggering sync etc.
    [_task setName:_taskChanges.name];
    [_task setNotes:_taskChanges.notes];
    [_task setCategories:_taskChanges.categories];
    [_task setReminderImportant:_taskChanges.reminderImportant];
    [_task setReminderDate:_taskChanges.reminderDate];
    
    NSError *error;
    [[IAADataAccess sharedDataAccess] saveChanges:&error];
    [IAAErrorManager checkError:error];
    
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

- (void)nameDidChange:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    _taskChanges.name = textField.text;
    [self setupNavigationBarItems];
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
            cell.textField.text = _taskChanges.name;
            cell.textField.tag = kTitleTextField;
            
            [cell.textField addTarget:self action:@selector(nameDidChange:) forControlEvents:UIControlEventEditingChanged];
            
            if (self.newMode)
                [cell.textField becomeFirstResponder];
            
            return cell;
        }
        case 1:
        {
            cellIdentifier = @"ReminderCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            cell = cell == nil ? [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] : cell;
            
            if (_taskChanges.reminderDate == nil)
            {
                cell.textLabel.text = @"Reminder";
                cell.textLabel.textColor = [UIColor lightGrayColor];
            }
            else
            {
                cell.textLabel.text = [[IAADateFormatter sharedFormatter] shortDateTimeStringFromDate:_taskChanges.reminderDate];
                cell.textLabel.textColor = _taskChanges.reminderImportant ? [UIColor blueColor] : [UIColor blackColor];
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        case 2:
        {
            cellIdentifier = @"CategoriesCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            cell = cell == nil ? [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] : cell;
            
            if ([_taskChanges.categories count] == 0)
            {
                cell.textLabel.text = @"Categories";
                cell.textLabel.textColor = [UIColor lightGrayColor];
            }
            else
            {
                NSString *text = self.categoriesText;
                cell.textLabel.text = text;
                cell.textLabel.textColor = [UIColor blackColor];
                cell.textLabel.numberOfLines = 9;
                cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell.textLabel.clipsToBounds = YES;
                
                CGSize expectedLabelSize = [text sizeWithFont:cell.textLabel.font constrainedToSize:CGSizeMake(300, kMaxLabelHeight) lineBreakMode:NSLineBreakByWordWrapping];
                
                CGRect frame = cell.textLabel.frame;
                frame.size = expectedLabelSize;
                cell.textLabel.frame = frame;
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        case 3:
        {
            cellIdentifier = @"NotesCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            cell = cell == nil ? [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] : cell;
            
            if (_taskChanges.notes == nil || [_taskChanges.notes iaa_isEmptyOrWhitespace])
            {
                cell.textLabel.text = @"Notes";
                cell.textLabel.textColor = [UIColor lightGrayColor];
            }
            else
            {
                cell.textLabel.text = _taskChanges.notes;
                cell.textLabel.textColor = [UIColor blackColor];
                cell.textLabel.numberOfLines = 9;
                cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell.textLabel.clipsToBounds = YES;
                                
                CGSize expectedLabelSize = [_taskChanges.notes sizeWithFont:cell.textLabel.font constrainedToSize:CGSizeMake(300, kMaxLabelHeight) lineBreakMode:NSLineBreakByWordWrapping];
                
                CGRect frame = cell.textLabel.frame;
                frame.size = expectedLabelSize;
                cell.textLabel.frame = frame;
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text;
    
    if (indexPath.row == 2)
    {
        text = [self categoriesText];
    }
    else if (indexPath.row == 3)
    {
        text = _taskChanges.notes;
    }
    
    if (text == nil || [text iaa_isEmptyOrWhitespace])
        return 44;
    
    UIFont *font = [UIFont systemFontOfSize:17.0];
        
    CGSize expectedLabelSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(300, kMaxLabelHeight) lineBreakMode:NSLineBreakByWordWrapping];
                
    return expectedLabelSize.height + (44 - font.lineHeight);
}

- (NSString *)categoriesText
{
    NSArray *names = [[_taskChanges.categories allObjects] iaa_mapObjectsUsingBlock:^(id category, NSUInteger idx) {
        return [category name];
    }];
    return [names componentsJoinedByString:@" | "];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row)
    {
        case 1:
        {
            IAAReminderViewController *rvc = [[IAAReminderViewController alloc] initWithTaskChanges:_taskChanges];
            [self.navigationController pushViewController:rvc animated:YES];
            break;
        }
        case 2:
        {
            IAACategoriesViewController *cvc = [[IAACategoriesViewController alloc] initWithSelectedCategories:_taskChanges.categories];
            [self.navigationController pushViewController:cvc animated:YES];
            cvc.delegate = self;
            break;
        }
        case 3:
        {
            IAANotesViewController *nvc = [[IAANotesViewController alloc] initWithNotes:_taskChanges.notes];
            nvc.delegate = self;
            [self.navigationController pushViewController:nvc animated:YES];
            break;
        }
    }
}

#pragma mark - Other delegates

- (void)notesViewController:(IAANotesViewController *)notesViewController editedNotes:(NSString *)notes
{
    _taskChanges.notes = notes;
}

- (void)categoriesViewController:(IAACategoriesViewController *)notesViewController selectedCategories:(NSSet *)categories
{
    [_taskChanges setCategories:categories];
}


@end
