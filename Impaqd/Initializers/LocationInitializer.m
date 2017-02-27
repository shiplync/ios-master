//
//  LocationInitializer.m
//  Impaqd
//
//  Created by Traansmission on 6/3/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "LocationInitializer.h"
#import "LocationCoordinator.h"

@interface LocationInitializer ()

@property (copy) InitializerCallback callback;

@end

@implementation LocationInitializer

- (instancetype)initWithCallback:(InitializerCallback)callback {
    NSParameterAssert(callback);
    
    self = [super init];
    if (self) {
        self.callback = callback;
    }
    return self;
}

- (void)didFinishLaunching {
    [[LocationCoordinator sharedInstance] startMonitoring];
    [[[LocationCoordinator sharedInstance] locationManager] disallowDeferredLocationUpdates];
    self.callback(nil);
}

- (void)willEnterForeground {
    [[LocationCoordinator sharedInstance] startMonitoring];
    [[[LocationCoordinator sharedInstance] locationManager] disallowDeferredLocationUpdates];
    self.callback(nil);
}

- (void)didEnterBackground {
    [[[LocationCoordinator sharedInstance] locationManager] allowDeferredLocationUpdatesUntilTraveled:kLocationCoordinatorPassiveDistanceThreshold timeout:kLocationCoordinatorPassiveTimeInterval];
}

@end
