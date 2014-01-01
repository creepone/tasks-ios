//
//  IAAAppDelegate.m
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "MBProgressHUD.h"
#import "IAAAppDelegate.h"
#import "IAAMainViewController.h"
#import "IAAMigrationManager.h"
#import "IAASyncManager.h"
#import "IAAColor.h"
#import "IAALog.h"
#import "IAAKeyboard.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

#define kMigrationErrorAlertTag 44

NSString * const IAALocalNotificationReceivedNotification = @"IAALocalNotificationReceivedNotification";

@interface IAAAppDelegate() <MBProgressHUDDelegate> {
    NSError *_migrationError;
    MBProgressHUD *_progressHud;
}

- (void)startDataInitialization;
- (void)initializeLogging;

@end

@implementation IAAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.mainViewController = [[IAAMainViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    
    [self.navigationController.navigationBar setTintColor:[IAAColor themeColor]];
    [self.navigationController.toolbar setTintColor:[IAAColor themeColor]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:self.navigationController];
    [self.window makeKeyAndVisible];
    
    // call to initialize listening to show/hide events
    [IAAKeyboard sharedKeyboard];
    
    [self initializeLogging];
    [self startDataInitialization];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if (![[IAASyncManager sharedManager] isActive])
        return;
    
    __block UIBackgroundTaskIdentifier backgroundTask;
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:backgroundTask];
    }];
    
    __block id observer;
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:IAASyncManagerFinishedSync object:nil queue:nil usingBlock:^(NSNotification *note) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
        [application endBackgroundTask:backgroundTask];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[IAASyncManager sharedManager] enqueueSync];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:IAALocalNotificationReceivedNotification object:self userInfo:@{@"notification": notification}];
}

#pragma mark - Data initialization on startup

- (void)startDataInitialization
{
    _progressHud = [[MBProgressHUD alloc] initWithWindow:self.window];
    
    [self.navigationController.view addSubview:_progressHud];
    _progressHud.delegate = self;
    _progressHud.graceTime = 1.0;
    _progressHud.labelText = @"Initializing data...";
    [_progressHud showWhileExecuting:@selector(performDataInitialization) onTarget:self withObject:nil animated:YES];
}

- (void)performDataInitialization
{
    @autoreleasepool {
        NSError *error;
        self.coreDataStack = [IAAMigrationManager coreDataStack:&error];
        
        if(error != nil) {
            _migrationError = error;
        }
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [_progressHud removeFromSuperview];
    _progressHud.delegate = nil;
    _progressHud = nil;
    
    if(self.coreDataStack == nil || _migrationError != nil) {
        DDLogError(@"Data initialization error: %@", [_migrationError localizedDescription]);
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"There was an error migrating the data"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [alert setTag:kMigrationErrorAlertTag];
        [alert show];
        return;
    }
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self.mainViewController loadData];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kMigrationErrorAlertTag) {
        exit(1);
    }
}

- (void)initializeLogging
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 24 * 60 * 60;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
}

@end
