//
//  IAASettingsViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAASettingsViewController.h"
#import "IAAIdentityManager.h"

@interface IAASettingsViewController ()

- (void)setupNavigationBarItems;
- (void)tappedDone;

@end

@implementation IAASettingsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Settings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavigationBarItems];
}

- (void)setupNavigationBarItems
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(tappedDone)];
}

- (void)tappedDone
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIdentifier];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Sync";
        
        IAAIdentityManager *identity = [IAAIdentityManager sharedManager];
        cell.detailTextLabel.text = (identity.username != nil) ? @"active" : @"setup";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        IAAIdentityManager *identity = [IAAIdentityManager sharedManager];
        
        if (identity.username == nil)
            [identity acquireIdentity];
    }
}

@end
