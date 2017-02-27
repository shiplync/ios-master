//
//  UserNotificationsPermissions.m
//  Impaqd
//
//  Created by Traansmission on 6/9/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "UserNotificationsPermissions.h"
#import <Aspects/Aspects.h>

@interface UserNotificationsPermissions ()

@property (nonatomic, readwrite) NSError *error;
@property (nonatomic) id<AspectToken> token;

@end

@implementation UserNotificationsPermissions

#pragma mark - PermissionsControllerProtocol Overrides

- (BOOL)isRegisteredForPermissions {
    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    UIUserNotificationType types = [settings types];
    return ((types & UIUserNotificationTypeBadge) && (types & UIUserNotificationTypeSound) && (types & UIUserNotificationTypeAlert));
}

- (dispatch_block_t)permissionBlockWithCompletion:(TRControllerCallback)completion {
    return ^{
        [self registerAspectHookWithCompletion:completion];
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    };
}


#pragma mark - Private Instance Methods

- (BOOL)validateUserNotificationSettings:(UIUserNotificationSettings *)settings {
    UIUserNotificationType types = [settings types];
    return (types & UIUserNotificationTypeAlert)
        && (types & UIUserNotificationTypeBadge)
        && (types & UIUserNotificationTypeSound);
}

- (BOOL)registerAspectHookWithCompletion:(TRControllerCallback)completion {
    NSObject<UIApplicationDelegate> *appDelegate = [[UIApplication sharedApplication] delegate];
    NSError *error;
    self.token = [appDelegate aspect_hookSelector:@selector(application:didRegisterUserNotificationSettings:)
                                      withOptions:AspectPositionInstead
                                       usingBlock:[self userNotificationBlockWithCompletion:completion]
                                            error:&error];
    return (error == nil);
}

- (id)userNotificationBlockWithCompletion:(TRControllerCallback)completion {
    return ^(id<AspectInfo> info, UIApplication *application, UIUserNotificationSettings *notificationSettings) {
        NSError *error;
        if (![self validateUserNotificationSettings:notificationSettings]) {
            error = [NSError errorWithDomain:NSCocoaErrorDomain
                                        code:NSIntegerMax
                                    userInfo:@{ NSLocalizedDescriptionKey : @"Invalid User Notification Settings",
                                                NSLocalizedFailureReasonErrorKey : @"Did Not Approve" }];
        }
        [self.token remove];
        if (completion) {
            completion(error);
        }
    };
}

@end
