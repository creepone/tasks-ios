//
//  IAASettingsViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "IAASettingsViewController.h"
#import "IAAIdentityManager.h"
#import "IAASyncManager.h"
#import "IAADefaultsManager.h"
#import "IAANotificationSounds.h"
#import "IAASoundsViewController.h"
#import "IAAColor.h"
#import "IAALogging.h"
#import "IAAErrorManager.h"

@interface IAASettingsViewController () <MFMailComposeViewControllerDelegate>

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
    
    // subscribe to identity change notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshIdentity) name:IAAIdentityManagerAcquiredIdentityNotification object:nil];
    
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[IAAColor tableViewBackgroundColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)setupNavigationBarItems
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(tappedDone)];
}

- (void)tappedDone
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)refreshIdentity
{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#ifdef DEBUG
    return 4;
#else
    return 3;
#endif
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
        
        NSString *state = @"Setup";
        if (identity.deviceToken != nil)
            state = [IAASyncManager isOnline] ? @"Active" : @"Offline";
        
        cell.detailTextLabel.text = state;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"Notification Sound";
        
        NSString *selectedSound = [IAADefaultsManager notificationSoundName];
        cell.detailTextLabel.text = [[IAANotificationSounds sharedSounds] labelForSound:selectedSound];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"Send logs";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 3) {
        cell.textLabel.text = @"Reset device token";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 290, 23)];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.textAlignment = NSTextAlignmentCenter;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleVersion"];
    label.text = [NSString stringWithFormat:@"Build %@", version];

    [footerView addSubview:label];

    return footerView;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        IAAIdentityManager *identity = [IAAIdentityManager sharedManager];
        
        if (identity.deviceToken == nil)
            [identity acquireIdentity];
        else {
            if ([IAASyncManager isOnline]) {
                [[IAASyncManager sharedManager] enqueueSync];
            }
        }
    }
    else if (indexPath.row == 1) {
        IAASoundsViewController *svc = [[IAASoundsViewController alloc] init];
        [self.navigationController pushViewController:svc animated:YES];
    }
    else if (indexPath.row == 2) {
        NSString *archivePath = [IAALogging archiveLogs];
        NSData *archiveData = [NSData dataWithContentsOfFile:archivePath];
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        [picker setToRecipients:@[@"tomas@iosapps.at"]];
        [picker setSubject:@"Log files"];
        [picker addAttachmentData:archiveData mimeType:@"application/zip" fileName:@"log.zip"];
        
        NSString *emailBody = @"Attached you'll find the log files from Tasks";
        [picker setMessageBody:emailBody isHTML:YES];
        
        [self presentViewController:picker animated:YES completion:nil];
    }
    else if (indexPath.row == 3) {
        IAAIdentityManager *identity = [IAAIdentityManager sharedManager];
        [identity resetIdentity];
        [self refreshIdentity];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [IAAErrorManager checkError:error];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
