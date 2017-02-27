//
//  APNSController.m
//  Impaqd
//
//  Created by Traansmission on 4/23/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "APNSController.h"
#import <Mixpanel/Mixpanel.h>
#import "Account.h"
#import "APISessionManager.h"
#import "AccountController.h"
#import "RootViewController.h"
#import "Shipment.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

#if DEBUG
#import "UIApplication+SimulatorRemoteNotifications.h"
#endif

@interface APNSController ()

@property (nonatomic, weak) UIApplication *application;

@end

@implementation APNSController

#pragma mark - Instance Methods

- (void)validateRemoteNotificationSettings {
    [self registerForRemoteNotifications];
    if (![self.application isRegisteredForRemoteNotifications]) {
        [self registerForRemoteNotifications];
    }
    else {
        [self checkRemoteNotificationsSettings];
    }
    
#if DEBUG
    //    [self.application listenForRemoteNotifications];
#endif
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    //Log the token for testing purpose
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"\U0001f627notification token: %@\U0001f627", token);
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"device_token"];
    [[APISessionManager sharedManager] registerDeviceToken:token
                                                parameters:nil
                                                   success:nil
                                                   failure:[self registerDeviceTokenFailureCallback]];
    
    
    //ANALYTICS START
    //Register for push notifications
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:[[[AccountController sharedInstance] activeUserAccount] email]];
    [mixpanel.people addPushDeviceToken:deviceToken];
    //ANALYTICS END
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    NSLog(@"Failed to setup push notifications: %@", error);
    
    //ANALYTICS START
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:[[[AccountController sharedInstance] activeUserAccount] email]];
    [mixpanel track:@"failed to register for push notification"];
    //ANALYTICS END
}

- (void)didReceiveRemoteNotification:(NSDictionary*)userInfo {
    UIApplicationState state = [self.application applicationState];
    UIViewController *rootVC = [[[self.application delegate] window] rootViewController];
    UIViewController *presentedVC = [rootVC presentedViewController];
    NSString *email = [userInfo  valueForKey:@"email"];
    
    id<AccountProtocol> activeAccount = [[AccountController sharedInstance] activeUserAccount];
    if (!activeAccount.isVerified || ![activeAccount.email isEqualToString:email]) {
        return;
    }
    
    
    if (state == UIApplicationStateActive && ![presentedVC isKindOfClass:[UIAlertController class]]) {
        NSString *type = nil;
        NSString *alertValue = nil;
        
        @try {
            type = [userInfo  valueForKey:@"type"];
            alertValue = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        }
        @catch (NSException *exception) {
            NSLog(@"Unable to extract values from push payload: \n%@",exception);
        }
        
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertValue
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *close = [UIAlertAction actionWithTitle:@"Close"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil];
        [alert addAction:close];
        
        if([userInfo  valueForKey:@"shipment_id"]) {
            UIAlertAction *show = [UIAlertAction actionWithTitle:@"Show"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             [self addMessageFromRemoteNotification:userInfo updateUI:YES];
                                                             
                                                             //ANALYTICS START
                                                             Mixpanel *mixpanel = [Mixpanel sharedInstance];
                                                             [mixpanel track:@"opened shipment form push notification"];
                                                             //ANALYTICS END
                                                         }];
            [alert addAction:show];
        }
        
        [rootVC presentViewController:alert animated:YES completion:nil];
    }else if (state == UIApplicationStateActive && [presentedVC isKindOfClass:[UIAlertController class]]){
        //Do nothing if we are already showing an alert. It probably means that we are receiving two of the same notifications due to duplicate registered platforms on the backend (e.g. multiple accounts with same device.
    }
    else {
        // Means state != UIApplicationStateActive
        [self addMessageFromRemoteNotification:userInfo updateUI:YES];
    }
}


- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI {
    
    NSString *type = nil;
    NSString *alertValue = nil;
    @try {
        type = [userInfo  valueForKey:@"type"];
        alertValue = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    } @catch (NSException *exception){
        NSLog(@"Unable to extract values from push payload: \n%@",exception);
    }
    
    NSNumber *shipment_id = [userInfo  valueForKey:@"shipment_id"];
    
    if(shipment_id){
        [[APISessionManager sharedManager] shipmentWithId:shipment_id
                                               parameters:nil
                                                  success:[self shipmentSuccessBlock]
                                                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                      NSLog(@"Unable to get shipment: %@", error.localizedDescription);
                                                  }];
    }
    
    //ANALYTICS START
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:[[[AccountController sharedInstance] activeUserAccount] email]];
    [mixpanel track:@"launched app from push notification" properties:@{@"alert message": alertValue}];
    //ANALYTICS END
}

#pragma mark - Private Property Overrides

- (UIApplication *)application {
    if (_application == nil) {
        _application = [UIApplication sharedApplication];
    }
    return _application;
}

#pragma mark - Private Instance Methods

- (APISessionFailureBlock)registerDeviceTokenFailureCallback {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Unable to update device token: %@", error.localizedDescription);
    };
}

- (BOOL)hasSettings {
    return [[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)];
}

- (void)registerForRemoteNotifications {
    if ([self hasSettings]) {
        [self registerForRemoteNotificationsWithSettings];
    }
    else {
        [self registerForRemoteNotificationsWithTypes];
    }
}

- (void)checkRemoteNotificationsSettings {
    if ([self hasSettings]) {
        [self checkRemoteNotificationsWithSettings];
    }
    else {
        [self checkRemoteNotificationsWithTypes];
    }
}

- (void)registerForRemoteNotificationsWithSettings {
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)registerForRemoteNotificationsWithTypes {
    UIRemoteNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
}

- (void)checkRemoteNotificationsWithSettings {
    UIUserNotificationSettings *settings = [self.application currentUserNotificationSettings];
    UIUserNotificationType types = [settings types];
    if (!(types & UIUserNotificationTypeBadge) || !(types & UIUserNotificationTypeSound) || !(types & UIUserNotificationTypeAlert)) {
        [self presentRemoteNotificationsSettingsAlert];
    }
}

- (void)checkRemoteNotificationsWithTypes {
    UIRemoteNotificationType types = [self.application enabledRemoteNotificationTypes];
    if (!(types & UIRemoteNotificationTypeBadge) || !(types & UIRemoteNotificationTypeSound) || !(types & UIRemoteNotificationTypeAlert)) {
        [self presentRemoteNotificationsSettingsAlert];
    }
}

- (void)presentRemoteNotificationsSettingsAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notification Settings Disabled"
                                                                   message:@"In order to best use Traansmission, please open this app's settings and enable all notifications"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:cancel];
    
    UIAlertAction *openSettings = [UIAlertAction actionWithTitle:@"Open Settings"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                             [self.application openURL:url];
                                                         }];
    [alert addAction:openSettings];
    [[[[self.application delegate] window] rootViewController] presentViewController:alert animated:YES completion:nil];
}

- (APISessionSuccessBlock)shipmentSuccessBlock {
    
    return ^(NSURLSessionDataTask *task, id responseObject) {
        NSError *error;
        NSMutableDictionary *mutJSONDictionary = [(NSDictionary *)responseObject mutableCopy];
        NSUInteger count = [mutJSONDictionary[@"count"] integerValue];
        RootViewController *rootVC = [(AppDelegate *)[self.application delegate] rootViewController];
        Shipment *shipment  = nil;
        if (count != 0) {
            NSArray *results = mutJSONDictionary[@"results"];
            NSArray *shipments = [MTLJSONAdapter modelsOfClass:[Shipment class] fromJSONArray:results error:&error];
            shipment = shipments[0];
        }
        [rootVC presentShipmentDetails:shipment];
    };
}



@end
