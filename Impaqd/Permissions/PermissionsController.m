//
//  PermissionsController.m
//  SemaphoreScratch
//
//  Created by Traansmission on 5/22/15.
//  Copyright (c) 2015 Traansmission. All rights reserved.
//

#import "PermissionsController.h"
#import "PermissionsProtocol.h"
#import <CoreLocation/CoreLocation.h>

static NSMutableArray *__permissionClasses;

@interface PermissionsController ()

@property (nonatomic) dispatch_queue_t dispatchQueue;
@property (nonatomic) dispatch_semaphore_t permissionsSemaphore;
@property (nonatomic) NSArray *permissionClasses;

@end;

@implementation PermissionsController

+ (void)load {
    __permissionClasses = [NSMutableArray array];
}

+ (BOOL)registerClass:(Class)aClass {
    if ([aClass conformsToProtocol:@protocol(PermissionsProtocol)]) {
        if (![__permissionClasses containsObject:aClass]) {
            [__permissionClasses addObject:aClass];
        }
        return YES;
    }
    return NO;
}

+ (void)unregisterClass:(Class)aClass {
    [__permissionClasses removeObject:aClass];
}

#pragma mark - Object Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dispatchQueue = dispatch_queue_create([[[self class] description] UTF8String], DISPATCH_QUEUE_SERIAL);
        self.permissionClasses = [NSArray arrayWithArray:__permissionClasses];
    }
    return self;
}


#pragma mark - Instance Methods

- (void)registerForPermissions:(TRControllerCallback)completion {
    for (Class permissionClass in self.permissionClasses) {
        id<PermissionsProtocol> permissionObject = [[permissionClass alloc] init];
        if (![permissionObject isRegisteredForPermissions]) {
            dispatch_block_t permissionBlock = [permissionObject permissionBlockWithCompletion:^(NSError *error){
                if (error) {
                    if (completion) {
                        completion(error);
                        return;
                    }
                }
                if (self.permissionsSemaphore) {
                    dispatch_semaphore_signal(self.permissionsSemaphore);
                }
            }];
            dispatch_async(self.dispatchQueue, [self permissionsSemaphoreBlockWithBlock:permissionBlock completion:^(NSError *error) {
                if (completion && [permissionClass isEqual:[self.permissionClasses lastObject]]) {
                    completion(error);
                }
            }]);
        }
        else {
            if (completion && [permissionClass isEqual:[self.permissionClasses lastObject]]) {
                completion(nil);
            }
        }
    }
}
    
    
//- (void)didFailToRegisterForRemoteNotifications {
//    if (self.permissionsSemaphore) {
//        dispatch_semaphore_signal(self.permissionsSemaphore);
//        self.permissionsSemaphore = NULL;
//    }
//
//    if (self.remoteNotificationsCompletion) {
//        self.remoteNotificationsCompletion([NSError errorWithCode:TRErrorRemoteNotificationsDenied description:@"Remote Notifications Required"]);
//    }
//}

//    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
//    if (!locationServicesEnabled) {
//        [self showEnableLocationServiceAlert];
//        return;
//    }
//
//    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
//    if (authorizationStatus == kCLAuthorizationStatusRestricted
//        || authorizationStatus == kCLAuthorizationStatusDenied) {
//        [self showEnableLocationSettingsAlert];
//        return;
//    }

//- (void)showEnableLocationServiceAlert {
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enable Location Services"
//                                                                   message:@"In order to find Shipments, we need to know you current location. Open Settings, select \"Privacy\", and turn on \"Location Services\"."
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *notNowAction = [UIAlertAction actionWithTitle:@"Not Now"
//                                                           style:UIAlertActionStyleDestructive
//                                                         handler:nil];
//    [alert addAction:notNowAction];
//    UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"Open Settings"
//                                                         style:UIAlertActionStyleCancel
//                                                       handler:^(UIAlertAction *action) {
//                                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//                                                       }];
//    [alert addAction:openAction];
////    [self presentViewController:alert animated:YES completion:nil];
//}
//
//- (void)showEnableLocationSettingsAlert {
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location Permissions Needed"
//                                                                   message:@"In order to find Shipments, we need to know you current location. Open the application settings. Select \"Location\" and select \"Always\"."
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *notNowAction = [UIAlertAction actionWithTitle:@"Not Now"
//                                                           style:UIAlertActionStyleDestructive
//                                                         handler:nil];
//    [alert addAction:notNowAction];
//    UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"Open Settings"
//                                                         style:UIAlertActionStyleCancel
//                                                       handler:^(UIAlertAction *action) {
//                                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//                                                       }];
//    [alert addAction:openAction];
////    [self presentViewController:alert animated:YES completion:nil];
//}


#pragma mark - Private Instance Methods

- (dispatch_block_t)permissionsSemaphoreBlockWithBlock:(dispatch_block_t)block completion:(TRControllerCallback)completion {
    return ^{
        self.permissionsSemaphore = dispatch_semaphore_create(0);
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block();
            }
        });
    
        dispatch_semaphore_wait(self.permissionsSemaphore, DISPATCH_TIME_FOREVER);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(nil);
            }
        });
    };
}

@end
