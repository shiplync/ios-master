//
//  RemoteNotificationsPermissions.m
//  Impaqd
//
//  Created by Traansmission on 6/9/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "RemoteNotificationsPermissions.h"
#import "UIApplication+SimulatorRemoteNotifications.h"
#import <Aspects/Aspects.h>
#import "AppDelegate.h"
#import "APNSController.h"

@interface RemoteNotificationsPermissions ()

@property (nonatomic, readwrite) NSError *error;
@property (nonatomic) id<AspectToken> successToken;
@property (nonatomic) id<AspectToken> failureToken;

@end

@implementation RemoteNotificationsPermissions

#pragma mark - PermissionsControllerProtocol Overrides

- (BOOL)isRegisteredForPermissions {
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        return YES;
    }
    else {
        return NO;
    }
}

- (dispatch_block_t)permissionBlockWithCompletion:(TRControllerCallback)completion {
    return ^{
        [self registerAspectHooksWithCompletion:completion];
#if TARGET_IPHONE_SIMULATOR
        [[UIApplication sharedApplication] listenForRemoteNotifications];
#endif
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    };
}


#pragma mark - Private Instance Methods

- (BOOL)registerAspectHooksWithCompletion:(TRControllerCallback)completion {
    NSObject<UIApplicationDelegate> *appDelegate = [[UIApplication sharedApplication] delegate];
    NSError *error;
    
    self.successToken = [appDelegate aspect_hookSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)
                                             withOptions:AspectPositionInstead
                                              usingBlock:[self successRemoteNotificationsBlockWithCompletion:completion]
                                                   error:&error];
    if (error) {
        return NO;
    }
    
    self.failureToken = [appDelegate aspect_hookSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)
                                             withOptions:AspectPositionInstead
                                              usingBlock:[self failRemoteNotificationsBlockWithCompletion:completion]
                                                   error:&error];
    if (error) {
        [self.successToken remove];
    }
    
    return (error == nil);
}

- (id)successRemoteNotificationsBlockWithCompletion:(TRControllerCallback)completion {
    return ^(id<AspectInfo> info, UIApplication *application, NSData *deviceToken) {
        APNSController *apnsController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] apnsController];
        [apnsController didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
        [self.successToken remove];
        [self.failureToken remove];
        if (completion) {
            completion(nil);
        }
    };
}

- (id)failRemoteNotificationsBlockWithCompletion:(TRControllerCallback)completion {
    return ^(id<AspectInfo> info, UIApplication *application, NSError *error) {
        self.error = error;
        [self.successToken remove];
        [self.failureToken remove];
        if (completion) {
            completion(error);
        }
    };
}

@end