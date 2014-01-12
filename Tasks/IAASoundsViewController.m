//
//  IAASoundsViewController.m
//  Tasks
//
//  Created by Tomas Vana on 12/01/14.
//  Copyright (c) 2014 iOS Apps Austria. All rights reserved.
//

#import "IAASoundsViewController.h"
#import "IAAColor.h"
#import "IAANotificationSounds.h"
#import "IAADefaultsManager.h"
#import "IAANotificationManager.h"

@implementation IAASoundsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Sounds";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[IAAColor tableViewBackgroundColor]];
    
    [self.navigationController.toolbar setTintColor:[IAAColor themeColor]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[IAANotificationSounds sharedSounds] allSounds] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = cell == nil ? [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] : cell;
    
    IAANotificationSounds *sounds = [IAANotificationSounds sharedSounds];
    NSString *selectedSound = [IAADefaultsManager notificationSoundName];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = [sounds labelForSound:nil];
        cell.accessoryType = selectedSound == nil ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    else {
        NSString *soundName = [[sounds allSounds] objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = [sounds labelForSound:soundName];
        cell.accessoryType = [selectedSound isEqualToString:soundName] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [IAADefaultsManager setNotificationSoundName:nil];
    }
    else {
        IAANotificationSounds *sounds = [IAANotificationSounds sharedSounds];
        NSString *soundName = [[sounds allSounds] objectAtIndex:indexPath.row - 1];
        [IAADefaultsManager setNotificationSoundName:soundName];
        
        [sounds playSound:soundName];
    }
    
    [[IAANotificationManager sharedManager] rescheduleAll];
    [tableView reloadData];
}


@end
