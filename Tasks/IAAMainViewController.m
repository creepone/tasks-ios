//
//  IAAMainViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAAMainViewController.h"
#import "IAASettingsViewController.h"
#import "IAATaskViewController.h"
#import "IAATasksViewController.h"
#import "IAAErrorManager.h"
#import "IAAColor.h"
#import "IAADataAccess.h"
#import "IAADateCalculator.h"
#import "IAAAppDelegate.h"

@interface IAAMainViewController () {
    NSFetchedResultsController *_fetchedResultsController;
    BOOL _emptyMode;
}

- (void)refreshData;
- (void)setupToolbarItems;
- (void)tappedSettings;
- (NSInteger)countOfCategories;
- (NSIndexPath *)controllerPath:(NSIndexPath *)tableViewIndexPath;

@end

@implementation IAAMainViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Tasks";
        _emptyMode = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localNotificationReceived:) name:IAALocalNotificationReceivedNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupToolbarItems];
    
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[IAAColor tableViewBackgroundColor]];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self refreshData];
}

- (void)loadData
{
    _emptyMode = NO;
    _fetchedResultsController = [[IAADataAccess sharedDataAccess] fetchedResultsControllerForAllCategories];
    
    [self refreshData];
}

- (void)refreshData
{
    if (_emptyMode)
        return;
    
    NSError *error;
    [_fetchedResultsController performFetch:&error];
    [IAAErrorManager checkError:error];
    
    [self.tableView reloadData];
}

- (void)setupToolbarItems
{
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(tappedAdd)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *confItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbarIcon_conf.png"] style:UIBarButtonItemStylePlain target:self action:@selector(tappedSettings)];
    
    self.toolbarItems = @[addItem, flexibleSpace, confItem];
    [self.navigationController setToolbarHidden:NO];
}

- (void)tappedAdd
{
    IAATaskViewController *tvc = [[IAATaskViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tvc];
    [navigationController.navigationBar setTintColor:[IAAColor themeColor]];
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)tappedSettings
{
    IAASettingsViewController *svc = [[IAASettingsViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:svc];
    [navigationController.navigationBar setTintColor:[IAAColor themeColor]];
    [navigationController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)localNotificationReceived:(NSNotification *)notification
{
    [self refreshData];
}

#pragma mark - Table view data source

- (NSInteger)countOfCategories
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_emptyMode)
        return 0;
    
    if (section == 0)
        return 2;
    
    NSInteger countOfUncategorized = [[IAADataAccess sharedDataAccess] countOfTasksInCategory:nil];
    NSInteger offset = countOfUncategorized > 0 ? 1 : 0;    
    return [self countOfCategories] + offset;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell = cell == nil ? [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIdentifier] : cell;
    
    IAADataAccess *dataAccess = [IAADataAccess sharedDataAccess];
    IAADateCalculator *calculator = [IAADateCalculator sharedCalculator];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {            
            cell.textLabel.text = @"Due";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [dataAccess countOfTasksDueUntil:[NSDate date]]];
        }
        else {
            NSDate *midnightIn5Days = [calculator datePart:[calculator dateWithDate:[NSDate date] daysLater:5]];

            cell.textLabel.text = @"Soon";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [dataAccess countOfTasksDueBetween:[NSDate date] and:midnightIn5Days]];
        }
    }
    else if (indexPath.row < self.countOfCategories)
    {
        IAACategory *category = [_fetchedResultsController objectAtIndexPath:[self controllerPath:indexPath]];
        cell.textLabel.text = category.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [dataAccess countOfTasksInCategory:category]];
    }
    else
    {
        cell.textLabel.text = @"Uncategorized";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [dataAccess countOfTasksInCategory:nil]];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        IAATasksViewController *tvc;
        IAADateCalculator *calculator = [IAADateCalculator sharedCalculator];

        if (indexPath.row == 0) {
            tvc = [[IAATasksViewController alloc] initWithDueDate:[NSDate date] title:@"Due"];
        }
        else {
            NSDate *midnightIn5Days = [calculator datePart:[calculator dateWithDate:[NSDate date] daysLater:5]];
            tvc = [[IAATasksViewController alloc] initWithDatesBetween:[NSDate date] and:midnightIn5Days title:@"Soon"];
        }
        
        [self.navigationController pushViewController:tvc animated:YES];
    }
    else if (indexPath.section == 1)
    {
        IAACategory *category = nil;
        
        if (indexPath.row < self.countOfCategories)
            category = [_fetchedResultsController objectAtIndexPath:[self controllerPath:indexPath]];
        
        IAATasksViewController *tvc = [[IAATasksViewController alloc] initWithCategory:category];
        [self.navigationController pushViewController:tvc animated:YES];
    }
}

- (NSIndexPath *)controllerPath:(NSIndexPath *)tableViewIndexPath
{
    return [NSIndexPath indexPathForRow:tableViewIndexPath.row inSection:0];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
