//
//  IAAIdentityManager.m
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAAIdentityManager.h"
#import "IAAErrorManager.h"
#import "IAADefaultsManager.h"
#import "IAANetworkConfiguration.h"
#import "SFHFKeychainUtils.h"
#import "NSURL+PathParameters.h"

#import "IAAOpenidSelectViewController.h"
#import "IAAOpenidAccountViewController.h"

@interface IAAIdentityManager() <UIWebViewDelegate> {
    UINavigationController *_navigationController;
}

- (void)selectProvider;
- (void)selectAccount:(IAAOpenIDProvider) provider;
- (void)startAuthenticate:(IAAOpenIDProvider)provider account:(NSString *)account;

- (void)dismissAuthentication;

@end

@implementation IAAIdentityManager

static NSString *kServiceName = @"at.iosapps.Tasks";

- (id)init
{
    self = [super init];
    if (self) {
        NSError *error;
        self.username = [IAADefaultsManager username];
        
        if (self.username != nil) {
            self.deviceId = [SFHFKeychainUtils getPasswordForUsername:self.username andServiceName:kServiceName error:&error];
            [IAAErrorManager checkError:error];
        }
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
    // guide the user through the process of acquiring the identity
    [self selectProvider];
}

- (void)selectProvider
{
    IAAOpenidSelectViewController *osvc = [[IAAOpenidSelectViewController alloc] init];
    
    _navigationController = [[UINavigationController alloc] initWithRootViewController:osvc];
    [_navigationController.navigationBar setTintColor:[UIColor redColor]];
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
    
    IAANetworkConfiguration *networkConfig = [IAANetworkConfiguration sharedConfiguration];
    [networkConfig refresh];

    NSURL *authenticateURL = [networkConfig authenticationURL];    
    if (authenticateURL == nil) {
        // todo: at this point, we are probably not online. show some message to the user and let him dismiss
        [_navigationController.view removeFromSuperview];
        _navigationController = nil;
        return;
    }
    
    authenticateURL = [authenticateURL URLByAppendingParameterName:@"openid" value:openid];
    
    // clear cookies to avoid automatic login into the last used account
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    UIViewController *dummyVc = [[UIViewController alloc] init];
    dummyVc.title = @"Authenticate";
    [_navigationController setViewControllers:@[dummyVc] animated:NO];
    
    // add cancel button in case something goes wrong in the web view
    dummyVc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissAuthentication)];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:dummyVc.view.bounds];
    [webView setDelegate:self];
    [webView loadRequest:[NSURLRequest requestWithURL:authenticateURL]];
    [dummyVc.view addSubview:webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // todo: go on in the process of authentication
    
    NSString *host = [[request URL] host];
    if ([host isEqualToString:@"done"]) {
        [webView removeFromSuperview];
    }
    
    NSLog(@"%@", [request URL]);
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // todo: show some message to the user to let him know
    [webView removeFromSuperview];
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
