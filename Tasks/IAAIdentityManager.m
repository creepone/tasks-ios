//
//  IAAIdentityManager.m
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAAIdentityManager.h"
#import "IAAErrorManager.h"
#import "IAASyncManager.h"
#import "IAADefaultsManager.h"
#import "IAANetworkConfiguration.h"
#import "SFHFKeychainUtils.h"
#import "NSURL+GHUtils.h"
#import "NSString+Extensions.h"
#import "IAAColor.h"

#import "IAAOpenidSelectViewController.h"
#import "IAAOpenidAccountViewController.h"

NSString * const IAAIdentityManagerAcquiredIdentityNotification = @"IAAIdentityManagerAcquiredIdentityNotification";

@interface IAAIdentityManager() <UIWebViewDelegate> {
    UINavigationController *_navigationController;
}

- (void)selectProvider;
- (void)selectAccount:(IAAOpenIDProvider) provider;
- (void)startAuthenticate:(IAAOpenIDProvider)provider account:(NSString *)account;

- (void)dismissAuthentication;

@end

@implementation IAAIdentityManager

static NSString *kUsername = @"username";
static NSString *kServiceName = @"at.iosapps.Tasks";

- (id)init
{
    self = [super init];
    if (self) {
        NSError *error;
        self.deviceToken = [SFHFKeychainUtils getPasswordForUsername:kUsername andServiceName:kServiceName error:&error];
        [IAAErrorManager checkError:error];
    }
    return self;
}

+ (IAAIdentityManager *)sharedManager
{
    static dispatch_once_t once;
    static IAAIdentityManager *sharedManager;
    dispatch_once(&once, ^ { sharedManager = [[self alloc] init]; });
    return sharedManager;
}

- (void)acquireIdentity
{
    if (self.deviceToken != nil)
        return;
    
    // guide the user through the process of acquiring the identity
    [self selectProvider];
}

- (void)selectProvider
{
    IAAOpenidSelectViewController *osvc = [[IAAOpenidSelectViewController alloc] init];
    
    _navigationController = [[UINavigationController alloc] initWithRootViewController:osvc];
    [_navigationController.navigationBar setTintColor:[IAAColor themeColor]];
    _navigationController.view.frame = [[UIScreen mainScreen] applicationFrame];
    
    osvc.callbackSelect = ^(IAAOpenIDProvider provider) {
        switch (provider) {
            case IAAOpenIDProviderGoogle:
            case IAAOpenIDProviderYahoo:
                [self startAuthenticate:provider account:nil];
                break;
            default:
                [self selectAccount:provider];
                break;
        }
    };
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:_navigationController.view];
    _navigationController.view.alpha = 0.0;
    
    [UIView animateWithDuration:1.0 animations:^{
        _navigationController.view.alpha = 1.0;
    }];
}

- (void)selectAccount:(IAAOpenIDProvider) provider
{
    IAAOpenidAccountViewController *avc = [[IAAOpenidAccountViewController alloc] init];
    [avc setProvider:provider];
    
    avc.callbackDone = ^(NSString *account) {
        [self startAuthenticate:provider account:account];
    };
    
    [_navigationController setViewControllers:@[avc] animated:NO];
}

- (void)startAuthenticate:(IAAOpenIDProvider)provider account:(NSString *)account
{
    NSString *openid;
    
    switch (provider)
    {
        case IAAOpenIDProviderGoogle:
            openid = @"https://www.google.com/accounts/o8/id";
            break;
        case IAAOpenIDProviderYahoo:
            openid = @"http://me.yahoo.com/";
            break;
        case IAAOpenIDProviderAol:
            openid = [NSString stringWithFormat:@"http://openid.aol.com/%@", account];
            break;
        case IAAOpenIDProviderMyOpenID:
            openid = [NSString stringWithFormat:@"http://%@.myopenid.com/", account];
            break;
        case IAAOpenIDProviderGeneric:
            openid = account;
            break;
    }
    
    UIViewController *dummyVc = [[UIViewController alloc] init];
    dummyVc.title = @"Authenticate";
    [_navigationController setViewControllers:@[dummyVc] animated:NO];
    
    // add cancel button in case something goes wrong in the web view
    dummyVc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissAuthentication)];
    
    IAANetworkConfiguration *networkConfig = [IAANetworkConfiguration sharedConfiguration];
    [networkConfig refresh];

    NSURL *authenticateURL = [networkConfig authenticationURL];
    if (authenticateURL == nil) {
        [self showError];
        return;
    }
    
    NSString *query = [NSURL gh_dictionaryToQueryString:@{ @"openid": openid, @"device": [[UIDevice currentDevice] name] }];
    authenticateURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [authenticateURL absoluteString], query]];
    
    // clear cookies to avoid automatic login into the last used account
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
        
    UIWebView *webView = [[UIWebView alloc] initWithFrame:dummyVc.view.bounds];
    [webView setDelegate:self];
    [webView loadRequest:[NSURLRequest requestWithURL:authenticateURL]];
    [dummyVc.view addSubview:webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{    
    NSString *host = [[request URL] host];    
    if ([host isEqualToString:@"done"])
    {
        NSDictionary *params = [[request URL] gh_queryDictionary];
        NSString *token = [params valueForKey:@"token"];
                
        NSError *error;
        [SFHFKeychainUtils storeUsername:kUsername andPassword:token forServiceName:kServiceName updateExisting:YES error:&error];
        [IAAErrorManager checkError:error];
        
        self.deviceToken = token;
        
        [[IAASyncManager sharedManager] enqueueSync];
        [[NSNotificationCenter defaultCenter] postNotificationName:IAAIdentityManagerAcquiredIdentityNotification object:self];
        
        [self dismissAuthentication];
        return NO;
    }
    else if ([host isEqualToString:@"error"])
    {
        [self dismissAuthentication];
        return NO;
    }
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _navigationController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator startAnimating];
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // hide loading indicator
    _navigationController.topViewController.navigationItem.rightBarButtonItem = nil;
    
    [webView removeFromSuperview];
    [self showError];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // hide loading indicator
    _navigationController.topViewController.navigationItem.rightBarButtonItem = nil;
}

- (void)showError
{    
    UIViewController *dummyVc = _navigationController.topViewController;
    
    UIView *errorView = [[UIView alloc] initWithFrame:dummyVc.view.bounds];
    [errorView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 290, 70)];
    [label setText:@"There was an error loading the authentication service. Check your internet connection."];
    [label setNumberOfLines:3];
    [errorView addSubview:label];
    
    UIButton *dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 110, 310, 44)];
    [dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [[dismissButton titleLabel] setFont:[UIFont boldSystemFontOfSize:17.0]];

    [dismissButton setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [dismissButton setBackgroundImage:[UIImage imageNamed:@"button_pressed"] forState:UIControlStateHighlighted];
    [dismissButton addTarget:self action:@selector(dismissAuthentication) forControlEvents:UIControlEventTouchUpInside];
    [errorView addSubview:dismissButton];
    
    [dummyVc.view addSubview:errorView];
}

- (void)dismissAuthentication
{
    [UIView animateWithDuration:1.0 animations:^{
        _navigationController.view.alpha = 0.0;
    }
    completion:^(BOOL finished) {
        [_navigationController.view removeFromSuperview];
        _navigationController = nil;
    }];
}

@end
