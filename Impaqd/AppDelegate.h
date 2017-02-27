//
//  AppDelegate.h
//  Impaqd
//
//  Created by Greg Nicholas on 1/29/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationCoordinator.h"


@class RootViewController;
@class APNSController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) RootViewController *rootViewController;
@property (nonatomic, readonly) APNSController *apnsController;
@property (strong,nonatomic) LocationCoordinator *locationCordinator;

- (void)showRootViewController;

@end
