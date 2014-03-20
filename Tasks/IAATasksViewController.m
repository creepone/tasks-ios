//
//  IAATasksViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/16/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAATasksViewController.h"
#import "IAATaskViewController.h"
#import "IAADataAccess.h"
#import "IAANotificationManager.h"
#import "IAASyncManager.h"
#import "IAAErrorManager.h"
#import "IAAColor.h"

@interface IAATasksViewController () <NSFetchedResultsControllerDelegate, IAATaskViewControllerDelegate> {
    IAACategory *_category;
    BOOL _showingDue, _uncategorized;
    NSDate *_startDate;
    NSDate *_endDate;
    NSFetchedResultsController *_fetchedResultsController;
}

- (void)setupToolbarItems;
- (void)refreshData;
- (NSInteger)countOfTasks;

@end

@implementation IAATasksViewController

- (id)initWithCategory:(IAACategory *)category
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = category != nil ? category.name : @"Uncategorized";
        _category = category;
        _uncategorized = category == nil;
        _fetchedResultsController = [[IAADataAccess sharedDataAccess] fetchedResultsControllerForTasksOfCategory:category];
        [_fetchedResultsController setDelegate:self];
    }
    return self;
}

- (id)initWithDueTasks
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Due";
        _showingDue = YES;
        _fetchedResultsController = [[IAADataAccess sharedDataAccess] fetchedResultsControllerForDueTasks];
        [_fetchedResultsController setDelegate:self];
    }
    return self;
}

- (id)initWithDatesBetween:(NSDate *)startDate and:(NSDate *)endDate title:(NSString *)title
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = title;
        _startDate = startDate;
        _endDate = endDate;
        _fetchedResultsController = [[IAADataAccess sharedDataAccess] fetchedResultsControllerForTasksDueBetween:startDate and:endDate];
        [_fetchedResultsController setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[IAAColor tableViewBackgroundColor]];
    
    [self setupToolbarItems];
    
    NSError *error;
    [_fetchedResultsController performFetch:&error];
    [IAAErrorManager checkError:error];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:IAASyncManagerFinishedSync object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:UIApplicationDidBecomeActiveNotification object:nil];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self.tableView reloadData];
}

- (void)setupToolbarItems
{
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(tappedAdd)];
    
    self.toolbarItems = @[addItem];
    [self.navigationController setToolbarHidden:NO];
}

- (void)tappedAdd
{
    IAATaskViewController *tvc = [[IAATaskViewController alloc] init];
    if (_category != nil)
        [tvc setCategories:[NSSet setWithArray:@[_category]]];
    tvc.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tvc];
    [navigationController.navigationBar setTintColor:[IAAColor themeColor]];
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)refreshData
{
    NSError *error;
    [_fetchedResultsController performFetch:&error];
    [IAAErrorManager checkError:error];
    
    [self.tableView reloadData];
}

- (void)taskViewController:(IAATaskViewController *)taskViewController didSaveTask:(IAATask *)task created:(BOOL)created
{
    BOOL popToRoot = NO;
    
    if (_category && ![task.categories containsObject:_category])
        popToRoot = YES;
    if (_uncategorized && [task.categories count] > 0)
        popToRoot = YES;    
    else if (_showingDue && !task.isDue)
        popToRoot = YES;
    else if (_startDate && _endDate) {
        if (!task.reminderDate)
            popToRoot = YES;
        if ([_startDate compare:task.reminderDate] == NSOrderedDescending)
            popToRoot = YES;
        if ([_endDate compare:task.reminderDate] != NSOrderedDescending)
            popToRoot = YES;
    }
    
    if (created) {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (popToRoot)
            [self.navigationController popToRootViewControllerAnimated:NO];
    }
    else {
        if (popToRoot)
            [self.navigationController popToRootViewControllerAnimated:YES];
        else
            [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)countOfTasks
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.countOfTasks;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell = cell == nil ? [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] : cell;
    
    IAATask *task = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = task.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        IAATask *task = [_fetchedResultsController objectAtIndexPath:indexPath];
        [IAATask remove:task];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    IAATask *task = [_fetchedResultsController objectAtIndexPath:indexPath];
    IAATaskViewController *tvc = [[IAATaskViewController alloc] initWithTask:task];
    tvc.delegate = self;
    [self.navigationController pushViewController:tvc animated:YES];
}

#pragma mark - Fetched result controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
        {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
