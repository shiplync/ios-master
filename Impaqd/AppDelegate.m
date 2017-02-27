//
//  AppDelegate.m
//  Impaqd
//
//  Created by Greg Nicholas on 1/29/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "AppDelegate.h"

#import "constants.h"
#import "sharedConstants.h"
#import "ATConnect.h"
#import "UpdateVersionViewController.h"
#import "LoadAppViewController.h"

#import "InitializerController.h"
#import "APNSController.h"
#import "RootViewController.h"
#import "AccountController.h"
#import "LocationCoordinator.h"
#import "APISessionManager.h"

@interface AppDelegate ()

@property (nonatomic, readwrite) RootViewController *rootViewController;
@property (nonatomic, readwrite) APNSController *apnsController;
@property (nonatomic, readwrite) BOOL showInitializer;
@property (nonatomic, readwrite) BOOL reLaunched;
@property (nonatomic, readwrite) NSDictionary *remoteNotificationOptions;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        [self startSendingBackgroundLocationUpdate];
    }

    //Because we don't want a black background when while we are waiting.
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.apnsController = [[APNSController alloc] init];
    self.showInitializer = YES;
	self.reLaunched = YES;
    self.remoteNotificationOptions = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    [self setAppearance];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"need_init_permission"];
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
#warning - rework the background logic
    //    [self.initializerController didEnterBackground];
    self.showInitializer = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (self.showInitializer) {
        [self showInitializerView];
        self.showInitializer = NO;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // Declare this method for the AOP cross-cut in the UserNotificationsPermissions object
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Declare this method for the AOP cross-cut in the RemoteNotificationsPermissions object
    [self.apnsController didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    // Declare this method for the AOP cross-cut in the RemoteNotificationsPermissions object
#if !TARGET_IPHONE_SIMULATOR
    [self.apnsController didFailToRegisterForRemoteNotificationsWithError:error];
#endif
}


//If app running in foreground -- this method will be called right after getting the notification
//If app background/suspend -- this method will be called after clicking the notification,
//								and after 'applicationDidBecomeActive' gets called
//If the app not running -- this method won't be called

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
    self.remoteNotificationOptions = userInfo;
    [[self apnsController] didReceiveRemoteNotification:userInfo];
}

#pragma mark - Public Instance Methods

- (void)showRootViewController {
    [self.window setRootViewController:self.rootViewController];
    [self.window makeKeyAndVisible];
}


#pragma mark - Private Property Overrides

- (RootViewController *)rootViewController {
    if (_rootViewController == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        _rootViewController = (RootViewController *)[storyboard instantiateViewControllerWithIdentifier:@"mainStartVC"];
    }
    return _rootViewController;
}


#pragma mark - Private Instance Methods

- (InitializerCallback)initializerCallback {
    return ^(NSError *error) {
        if (error) {
            if ([error.domain isEqualToString:TRErrorDomain]) {
                if (error.code == TRErrorVersionCheckFailed) {
                    [self showUpdateAlert];
                    return;
                } else if (error.code == NSURLErrorUserAuthenticationRequired) {
                    [self showLoginRegisterView];
                    return;
                }
            }
            UIAlertController *alert = [UIAlertController alertControllerWithError:error];
            [[self.window rootViewController] presentViewController:alert animated:YES completion:nil];
            return;
        }
        if (self.remoteNotificationOptions && self.reLaunched) {
            [self.apnsController addMessageFromRemoteNotification:self.remoteNotificationOptions updateUI:NO];
            self.remoteNotificationOptions = nil;
        }
		self.reLaunched = NO;
        [self takeToHomeScreen];
    };
}

- (void)takeToHomeScreen
{
    id<AccountProtocol> activeAccount = [[AccountController sharedInstance] activeUserAccount];
    if (activeAccount.isVerified) {
        [self showRootViewController];
    }
    else {
        [self showVerificationView];
    }
}

- (void)showInitializerView {
    LoadAppViewController *waitingController = [[LoadAppViewController alloc] initWithCallback:[self initializerCallback]];
    waitingController.view.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:waitingController];
    [self.window makeKeyAndVisible];
}

- (void)showLoginRegisterView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Register" bundle:nil];
    UIViewController *initViewController = [storyboard instantiateInitialViewController];
    [self.window setRootViewController:initViewController];
    [self.window makeKeyAndVisible];
}

- (void)showUpdateAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Update Needed"
                                                                   message:@"Your copy of Traansmission is out of date. Please download an updated version."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/traansmission/id833771825?mt=8"];
                                                       [[UIApplication sharedApplication] openURL:url];
                                                   }];
    [alert addAction:action];
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)showUpdateView {
    self.window.rootViewController = [[UpdateVersionViewController alloc] initWithNibName:@"UpdateVersionViewController" bundle:nil];
    [self.window makeKeyAndVisible];
}

- (void)showVerificationView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *initViewController = [storyboard instantiateInitialViewController];
    [self.window setRootViewController:initViewController];
    [self.window makeKeyAndVisible];
}

- (void)setAppearance {
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UITabBar appearance] setTranslucent:NO];
}

- (void)startSendingBackgroundLocationUpdate {
    self.locationCordinator = [[LocationCoordinator alloc] initWithLocationManager:[[CLLocationManager alloc] init]];
}




@end
