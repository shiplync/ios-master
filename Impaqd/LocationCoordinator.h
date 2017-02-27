//
//  LocationCoordinator.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/20/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "ShipmentTrackingDelegate.h"
#import "ShipmentRegionEventDelegate.h"
#import "RefreshMapDelegate.h"


FOUNDATION_EXPORT const CLLocationDistance kLocationCoordinatorDefaultRadius;
FOUNDATION_EXPORT const CLLocationDistance kLocationCoordinatorActiveDistanceThreshold;
FOUNDATION_EXPORT const CLLocationDistance kLocationCoordinatorPassiveDistanceThreshold;
FOUNDATION_EXPORT const NSTimeInterval     kLocationCoordinatorActiveTimeInterval;
FOUNDATION_EXPORT const NSTimeInterval     kLocationCoordinatorPassiveTimeInterval;
FOUNDATION_EXPORT const NSString          *kLocationCoordinatorRegionIdentifier;


/**
 *  Singleton coordinator for all geolocation-related tasks in Impaqd. This includes:
 *  - Querying the current location for search filtering
 *  - Periodic broadcasting of location while shipment is active
 *  - Region monitoring for pick-up/delivery locations
 */
@interface LocationCoordinator : NSObject <CLLocationManagerDelegate>

@property (nonatomic, readonly) CLLocationManager *locationManager;
@property (nonatomic, readonly) CLLocation        *lastLocation;
@property (nonatomic, readonly) CLRegion          *region;
@property (strong,nonatomic)    CLLocation        *activeLocation;

@property (nonatomic, readonly) CLAuthorizationStatus authorizationStatus;
@property (nonatomic, readonly, getter=isStatusNotDetermined) BOOL statusNotDetermined;
@property (nonatomic, readonly, getter=isEnabledWhileInUse) BOOL enabledWhileInUse;

@property (nonatomic, readonly, getter=isMonitoring) BOOL monitoring;

+ (instancetype)sharedInstance;
- (instancetype)initWithLocationManager:(CLLocationManager *)locationManager;

- (void)startMonitoring;
- (void)stopMonitoring;

- (void)monitorRegionWithCoordinate:(CLLocationCoordinate2D)coordinate;


#pragma mark - Deprecated Properties and Methods

@property (nonatomic, weak) id<ShipmentRegionEventDelegate> regionEventDelegate;
@property (nonatomic, weak) id<ShipmentTrackingDelegate> trackingDelegate;
@property (nonatomic, weak) id<RefreshMapDelegate> refreshMapDelegate;


+ (BOOL)areLocationServicesAvailable DEPRECATED_ATTRIBUTE;

- (void)startActiveLocationUpdates DEPRECATED_ATTRIBUTE;
- (void)stopActiveLocationUpdates DEPRECATED_ATTRIBUTE;

- (void)startTrackingShipment DEPRECATED_ATTRIBUTE;
- (void)stopTrackingShipment DEPRECATED_ATTRIBUTE;

- (void)startMonitoringPickUpCoordinate:(CLLocationCoordinate2D)coord DEPRECATED_ATTRIBUTE;
- (void)stopMonitoringPickUpCoordinate DEPRECATED_ATTRIBUTE;

- (void)startMonitoringDeliveryCoordinate:(CLLocationCoordinate2D)coord DEPRECATED_ATTRIBUTE;
- (void)stopMonitoringDeliveryCoordinate DEPRECATED_ATTRIBUTE;

@end

/**
 *  Key for notification when initial location is received
 */
extern NSString * const LocationCoordinatorInitialLocationReceived;