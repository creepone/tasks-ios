//
//  IAACategoriesViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/15/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAACategoriesViewController.h"
#import "IAADataAccess.h"
#import "IAAErrorManager.h"
#import "IAATextFieldCell.h"
#import "IAAColor.h"
#import "NSString+Extensions.h"
#import "NSObject+Extensions.h"

@interface IAACategoriesViewController () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
    NSMutableSet *_selectedCategories;
    BOOL _inReorderingOperation;
    BOOL _addingRow;
}

- (void)setupBarItems;
- (NSInteger)countOfCategories;
- (NSIndexPath *)controllerPath:(NSIndexPath *)tableViewIndexPath;

@end

@implementation IAACategoriesViewController

- (id)initWithSelectedCategories:(NSSet *)categories
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Categories";
        _selectedCategories = [categories mutableCopy];
        
        _fetchedResultsController = [[IAADataAccess sharedDataAccess] fetchedResultsControllerForAllCategories];
        [_fetchedResultsController setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[IAAColor tableViewBackgroundColor]];
    
    [self.navigationController.toolbar setTintColor:[IAAColor themeColor]];
    
    [self setupBarItems];
    
    NSError *error;
    [_fetchedResultsController performFetch:&error];
    [IAAErrorManager checkError:error];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.delegate categoriesViewController:self selectedCategories:_selectedCategories];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)setupBarItems
{
    if (_addingRow)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(tappedCancelAdd)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    
    UIBarButtonItem *itemAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(tappedAdd)];
    
    self.toolbarItems = @[itemAdd];
}

- (void)tappedAdd
{
    _addingRow = YES;
    
    NSIndexPath *firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self.tableView setEditing:NO animated:YES];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:firstRowIndexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:firstRowIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    [self setupBarItems];
}

- (void)commitAdd:(NSString *)name
{
    if(!_addingRow)
        return;
    
    if([name iaa_isEmptyOrWhitespace]) {
        [self tappedCancelAdd];
        return;
    }
    
    _addingRow = NO;
    [self setupBarItems];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
    
    IAADataAccess *dataAccess = [IAADataAccess sharedDataAccess];
    IAACategory *category = [dataAccess createObject:[IAACategory class]];
    
    category.name = name;
    category.order = 0;
    
    NSArray *allCategories = [[_fetchedResultsController fetchedObjects] mutableCopy];
    [IAACategory renumberAll:allCategories];
    
    NSError *error;
    [dataAccess saveChanges:&error];
    [IAAErrorManager checkError:error];
}

- (void)tappedCancelAdd
{
    _addingRow = NO;

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self setupBarItems];
}

#pragma mark - Table view data source

- (NSInteger)countOfCategories
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
    NSInteger count = [self countOfCategories];
    
    if(_addingRow)
        count++;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    BOOL editCell = _addingRow && indexPath.row == 0;
    NSString *cellIdentifier = editCell ? @"EditCell" : @"Cell";
    
    if (editCell) {
        IAATextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell = cell == nil ? [[IAATextFieldCell alloc] initWithReuseIdentifier:cellIdentifier] : cell;
        
        cell.textField.text = @"";
        cell.commitBlock = ^(NSString *text) {
            [self commitAdd:text];
        };
        
        [self iaa_performBlock:^{
            [cell.textField becomeFirstResponder];
        } afterDelay:0.01];
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = cell == nil ? [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] : cell;
    
    IAACategory *category = [_fetchedResultsController objectAtIndexPath:[self controllerPath:indexPath]];
    cell.textLabel.text = category.name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.accessoryType = [_selectedCategories containsObject:category] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IAACategory *category = [_fetchedResultsController objectAtIndexPath:[self controllerPath:indexPath]];
    if ([category.tasks count] == 0)
        return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSInteger indexFrom = [fromIndexPath row];
    NSInteger indexTo = [toIndexPath row];
    
    if(indexFrom != indexTo) {
        _inReorderingOperation = YES;
        
        NSMutableArray *allCategories = [[_fetchedResultsController fetchedObjects] mutableCopy];
        
        IAACategory *categoryToMove = [allCategories objectAtIndex:indexFrom];
        [allCategories removeObjectAtIndex:indexFrom];
        [allCategories insertObject:categoryToMove atIndex:indexTo];
        
        [IAACategory renumberAll:allCategories];
        
        NSError *error;
        [[IAADataAccess sharedDataAccess] saveChanges:&error];
        [IAAErrorManager checkError:error];
        
        _inReorderingOperation = NO;
    }
    
    if(fromIndexPath.row != toIndexPath.row)
        [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.02];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        IAACategory *category = [_fetchedResultsController objectAtIndexPath:[self controllerPath:indexPath]];
        
        // check again to be sure
        if ([category.tasks count] != 0)
            return;
        
        NSError *error;
        [[IAADataAccess sharedDataAccess] deleteObject:category error:&error];
        [IAAErrorManager checkError:error];
        
        [_selectedCategories removeObject:category];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IAACategory *category = [_fetchedResultsController objectAtIndexPath:[self controllerPath:indexPath]];

    if ([_selectedCategories containsObject:category])
        [_selectedCategories removeObject:category];
    else
        [_selectedCategories addObject:category];
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Fetched result controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if(_inReorderingOperation)
        return;
    
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
    if(_inReorderingOperation)
        return;
    
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
    
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if(_inReorderingOperation)
        return;
    
    [self.tableView endUpdates];
}

- (NSIndexPath *)controllerPath:(NSIndexPath *)tableViewIndexPath
{
    if(_addingRow) {
        return [NSIndexPath indexPathForRow:tableViewIndexPath.row - 1 inSection:tableViewIndexPath.section];
    }
    else
        return tableViewIndexPath;
}

@end
