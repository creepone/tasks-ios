//
//  IAAOpenidSelectViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAAOpenidSelectViewController.h"

@interface IAAOpenidSelectViewController ()

@end

@implementation IAAOpenidSelectViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"OpenID";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.rowHeight = 70.0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    
    
    NSString *logoImage = @"toolbarIcon_conf.png";
    CGRect frame = CGRectMake(80, 15, 160, 50);
    
    switch (indexPath.row) {
        case 0:
            logoImage = @"openid-google.png";
            frame = CGRectMake(80, 15, 160, 50);
            break;
        case 1:
            logoImage = @"openid-yahoo.png";
            frame = CGRectMake(80, 20, 160, 30);
            break;
        case 2:
            logoImage = @"openid-aol.png";
            frame = CGRectMake(120, 20, 80, 30);
            break;
        case 3:
            logoImage = @"openid-myopenid.png";
            frame = CGRectMake(100, 20, 120, 30);
            break;
        case 4:
            logoImage = @"openid.png";
            frame = CGRectMake(90, 10, 130, 45);
            break;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:logoImage]];
    imageView.frame = frame;
    [cell addSubview:imageView];
        
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Select your provider";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.callbackSelect == nil)
        return;
    
    switch (indexPath.row)
    {
        case 0:
            self.callbackSelect(IAAOpenIDProviderGoogle);
            break;
        case 1:
            self.callbackSelect(IAAOpenIDProviderYahoo);
            break;
        case 2:
            self.callbackSelect(IAAOpenIDProviderAol);
            break;
        case 3:
            self.callbackSelect(IAAOpenIDProviderMyOpenID);
            break;
        case 4:
            self.callbackSelect(IAAOpenIDProviderGeneric);
            break;
    }
}

@end
