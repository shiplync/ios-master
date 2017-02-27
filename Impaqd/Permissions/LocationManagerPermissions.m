//
//  LocationManagerPermissions.m
//  Impaqd
//
//  Created by Traansmission on 6/9/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "LocationManagerPermissions.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationManagerPermissions () <CLLocationManagerDelegate>

@property (nonatomic, readwrite) NSError *error;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL locationServicesEnabled;
@property (nonatomic) CLAuthorizationStatus authorizationStatus;
@property (nonatomic, copy) TRControllerCallback completion;

@end

@implementation LocationManagerPermissions

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationServicesEnabled = [CLLocationManager locationServicesEnabled];
        self.authorizationStatus = [CLLocationManager authorizationStatus];
    }
    return self;
}

#pragma mark - PermissionsControllerProtocol Overrides

- (BOOL)isRegisteredForPermissions {
    return self.locationServicesEnabled && (self.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways);
}

- (dispatch_block_t)permissionBlockWithCompletion:(TRControllerCallback)completion {
    self.completion = completion;
    return ^{
        self.locationManager.delegate = self;
        if (self.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestAlwaysAuthorization];
        }
    };
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSError *error;
    if (status != kCLAuthorizationStatusAuthorizedAlways) {
        if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
            error = [NSError errorWithDomain:TRErrorDomain code:TRErrorLocationServicesDenied userInfo:nil];
        }
        else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            error = [NSError errorWithDomain:TRErrorDomain code:TRErrorLocationServicesLimited userInfo:nil];
        }
    }
    self.locationManager.delegate = nil;
    if (self.completion) {
        self.completion(error);
    }
}


#pragma mark - Private Instance Methods


@end