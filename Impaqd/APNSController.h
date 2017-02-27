//
//  APNSController.h
//  Impaqd
//
//  Created by Traansmission on 4/23/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APNSController : NSObject

- (void)validateRemoteNotificationSettings;
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError*)error;
- (void)didReceiveRemoteNotification:(NSDictionary*)userInfo;
- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI;

@end
