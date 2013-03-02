//
//  IAAMainViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAAMainViewController.h"
#import "IAASettingsViewController.h"
#import "IAAErrorManager.h"

@interface IAAMainViewController ()

- (void)setupToolbarItems;
- (void)tappedSettings;

@end

@implementation IAAMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Tasks";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupToolbarItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

- (void)setupToolbarItems
{
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *confItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbarIcon_conf.png"] style:UIBarButtonItemStylePlain target:self action:@selector(tappedSettings)];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexibleSpace, confItem, nil];
    
    [self.navigationController setToolbarHidden:NO];
}

- (void)tappedSettings
{
    IAASettingsViewController *svc = [[IAASettingsViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:svc];
    [navigationController.navigationBar setTintColor:[UIColor redColor]];
    [navigationController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}


@end
