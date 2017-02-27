//
//  LocationCoordinator.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/20/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "LocationCoordinator.h"
#import "PermissionsController.h"

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import "HelperFunctions.h"
#import "Account.h"
#import "AppDelegate.h"
#import "APISessionManager.h"

const CLLocationDistance kLocationCoordinatorDefaultRadius            = 1000.0f;          // 1000 meters (1 km) (inactive)
const CLLocationDistance kLocationCoordinatorActiveDistanceThreshold  = 1000.0f;          // 1000 meters (1 km) (inactive)
const CLLocationDistance kLocationCoordinatorPassiveDistanceThreshold = 5.0f;             // 5 meters
const NSTimeInterval     kLocationCoordinatorActiveTimeInterval       = 10.0f * 60.0f;    // 10 minutes
const NSTimeInterval     kLocationCoordinatorPassiveTimeInterval      = 15.0f * 60.0f;    // 15 minutes (inactive)
const NSString          *kLocationCoordinatorRegionIdentifier         = @"kLocationCoordinatorRegionIdentifier";

static void * const LocationCoordinatorKVOContext = (void *)&LocationCoordinatorKVOContext;


static const NSTimeInterval secondsBetweenTrackingPings = 5 * 60;
static const NSTimeInterval secondsBetweenVagueTrackingPings = 30 * 60;

static NSString *pickUpRegionIdentifier = @"pickUpRegionIdentifier";
static NSString *deliveryRegionIdentifier = @"deliveryRegionIdentifier";

//static const CLLocationDistance monitoredRegionRadius = 3000;
static const CLLocationDistance monitoredRegionRadius = 1000;

NSString * const LocationCoordinatorInitialLocationReceived = @"LocationCoordinatorInitialLocationReceived";

@interface LocationCoordinator () {
    BOOL _isTrackingShipment;
    BOOL _usingFineLocationServices;
    BOOL _didPromptChangeLocation;
    
    CLCircularRegion *_monitoredPickUpRegion;
    CLCircularRegion *_monitoredDeliveryRegion;
    
    NSDate *_nextTrackingUpdateDue;
}

- (void)checkNowForPresenceInRegion:(CLRegion *)region;



@property (nonatomic, readwrite) CLLocationManager *locationManager;
@property (nonatomic, readwrite) CLLocation        *lastLocation;
@property (nonatomic, readwrite) CLLocation        *lastTrackingLocation;
@property (nonatomic, readwrite) CLRegion          *region;

@property (nonatomic, readwrite) CLAuthorizationStatus authorizationStatus;

@property (nonatomic, readwrite, getter=isMonitoring) BOOL monitoring;

@property (nonatomic)                            NSTimeInterval  timeInterval;
@property (nonatomic, readonly, getter=isActive) BOOL            active;

- (BOOL)isNewLocation:(CLLocation *)location;

@end

@implementation LocationCoordinator

+ (instancetype)sharedInstance {
    static LocationCoordinator *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        _sharedInstance = [[LocationCoordinator alloc] initWithLocationManager:locationManager];
    });
    return _sharedInstance;
}

+ (BOOL)automaticallyNotifiesObserversOfAuthorizationStatus {
    return NO;
}


#pragma mark - Object Lifecycle

- (instancetype)initWithLocationManager:(CLLocationManager *)locationManager {
    self = [super init];
    if (self) {
        self.locationManager = locationManager;
        self.locationManager.delegate = self;
        [self.locationManager requestAlwaysAuthorization];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.locationManager.activityType = CLActivityTypeOtherNavigation;
        
        _authorizationStatus = [CLLocationManager authorizationStatus];    // Don't Trigger KVO
        self.timeInterval = kLocationCoordinatorPassiveTimeInterval;
        
        [self startMonitoring];
        
        _isTrackingShipment = NO;
        _usingFineLocationServices = NO;
        _didPromptChangeLocation = NO;
    }
    return self;
}

- (void)dealloc {
}


#pragma mark - Property Overrides

- (BOOL)isStatusNotDetermined {
    return [CLLocationManager locationServicesEnabled]
    && (self.authorizationStatus == kCLAuthorizationStatusNotDetermined);
}

- (BOOL)isEnabledWhileInUse {
    return [CLLocationManager locationServicesEnabled]
    && (self.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse
        || self.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways);
}


#pragma mark - Public Instance Methods

- (void)startMonitoring {
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopMonitoring {
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)monitorRegionWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self.region) {
        [self.locationManager stopMonitoringForRegion:self.region];
    }
    CLCircularRegion *circularRegion = [[CLCircularRegion alloc] initWithCenter:coordinate
                                                                         radius:kLocationCoordinatorDefaultRadius
                                                                     identifier:(NSString *)kLocationCoordinatorRegionIdentifier];
    [self.locationManager startMonitoringForRegion:circularRegion];
}


#pragma mark - Private Property Overrides

- (BOOL)isActive {
    return self.region != nil;
}

- (void)setAuthorizationStatus:(CLAuthorizationStatus)authorizationStatus {
    if (_authorizationStatus != authorizationStatus) {
        [self willChangeValueForKey:@"authorizationStatus"];
        _authorizationStatus = authorizationStatus;
        [self didChangeValueForKey:@"authorizationStatus"];
    }
}


#pragma mark - Private Instance Methods

- (BOOL)isNewLocation:(CLLocation*)location {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastPostedGeoLocation"];
    if (!data) {
        return YES;
    }
    CLLocation *lastLocation = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!lastLocation) {
        return YES;
    }
    else if ([location.timestamp timeIntervalSinceDate:lastLocation.timestamp] > self.timeInterval && [location distanceFromLocation:lastLocation] > kLocationCoordinatorActiveDistanceThreshold) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.monitoring = YES;
    self.activeLocation = [locations lastObject];
    if ([self isNewLocation:self.activeLocation]) {
        [[APISessionManager sharedManager] postGeoLocation:self.activeLocation parameters:nil success:[self postGeoLocationSuccess] failure:nil];
    }
    [self startMonitoring];
}

- (APISessionSuccessBlock)postGeoLocationSuccess {
    return ^(NSURLSessionDataTask *task, id responseObject) {
        NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:self.activeLocation];
        [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"lastPostedGeoLocation"];
    };
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // NO-OP
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    // NO-OP
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    self.monitoring = NO;
    // NO-OP
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    self.monitoring = YES;
    // NO-OP
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    // NO-OP
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    return NO;
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    // NO-OP
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    // NO-OP
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    // use this method instead of didEnterRegion: because it'll also catch our queries to requestStateForRegion:
    if (state == CLRegionStateInside) {
        if ([region.identifier isEqualToString:pickUpRegionIdentifier]) {
            [self.regionEventDelegate didObservePickUpWithLocationCoordinator:self];
        }
        if ([region.identifier isEqualToString:deliveryRegionIdentifier]) {
            [self.regionEventDelegate didObserveDeliveryWithLocationCoordinator:self];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    // NO-OP
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    self.region = region;
    self.monitoring = YES;
}

/*
 - (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
 // NO-OP
 }
 
 - (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
 // NO-OP
 }
 
 - (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit {
 // NO-OP
 }
 */

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self setAuthorizationStatus:status];
}


#pragma mark - Potential Deprecated Methods

+ (BOOL)areLocationServicesAvailable
{
    return [CLLocationManager locationServicesEnabled] &&
    [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized;
}

- (void)startActiveLocationUpdates
{
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [self.locationManager startUpdatingLocation];
    _usingFineLocationServices = YES;
}

- (void)stopActiveLocationUpdates
{
    [self.locationManager stopUpdatingLocation];
    _usingFineLocationServices = NO;
}

//- (void)sendVagueLocationToServer:(CLLocation*) location
////This function can be seperated out of the file using delegates at some point.
//{
//    NSNumberFormatter *numberFmt = [[NSNumberFormatter alloc] init];
//    [numberFmt setNumberStyle:NSNumberFormatterDecimalStyle];
//    ISO8601DateFormatter *dateFmt = [[ISO8601DateFormatter alloc] init];
//    dateFmt.includeTime = YES;
//
//    NSDictionary *params = @{
//                             @"last_location_timestamp": [dateFmt stringFromDate:[NSDate date]],
//                             @"last_location": [[HelperFunctions sharedInstance] getServerCoordinateFromLocation:location]
//                             };
//    [[APISessionManager sharedManager] patchCarriersSingleWithParameters:params
//                                                                 success:nil
//                                                                 failure:^(NSURLSessionDataTask *task, NSError *error) {
//                                                                     NSLog(@"Unable to update carriers last location: %@", error.localizedDescription);
//                                                                 }];
//}

- (void)startTrackingShipment
{
    _isTrackingShipment = YES;
    _nextTrackingUpdateDue = [NSDate date];
    
    // try to use the SLC monitoring if possible. otherwise, use the least frequent basic monitoring
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
    else {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        [self.locationManager startUpdatingLocation];
        _usingFineLocationServices = YES;
    }
}

- (void)stopTrackingShipment
{
    _isTrackingShipment = NO;
    _nextTrackingUpdateDue = nil;
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        //Commented out because we always want to send location updates to server.
        //[self.locationManager stopMonitoringSignificantLocationChanges];
    }
    else {
        [self.locationManager stopUpdatingLocation];
        _usingFineLocationServices = NO;
    }
}

- (void)startMonitoringPickUpCoordinate:(CLLocationCoordinate2D)coord
{
    if (_monitoredPickUpRegion) {
        [self stopMonitoringPickUpCoordinate];
    }
    _monitoredPickUpRegion = [[CLCircularRegion alloc] initWithCenter:coord
                                                               radius:monitoredRegionRadius
                                                           identifier:pickUpRegionIdentifier];
    [self.locationManager startMonitoringForRegion:_monitoredPickUpRegion];
    
    [self checkNowForPresenceInRegion:_monitoredPickUpRegion];
}

- (void)stopMonitoringPickUpCoordinate
{
    [self.locationManager stopMonitoringForRegion:_monitoredPickUpRegion];
    _monitoredPickUpRegion = nil;
}

- (void)startMonitoringDeliveryCoordinate:(CLLocationCoordinate2D)coord
{
    if (_monitoredDeliveryRegion) {
        [self stopMonitoringDeliveryCoordinate];
    }
    
    _monitoredDeliveryRegion = [[CLCircularRegion alloc] initWithCenter:coord
                                                                 radius:monitoredRegionRadius
                                                             identifier:deliveryRegionIdentifier];
    [self.locationManager startMonitoringForRegion:_monitoredDeliveryRegion];
    
    // just in case, check if we're already in the region
    [self checkNowForPresenceInRegion:_monitoredDeliveryRegion];
}

- (void)stopMonitoringDeliveryCoordinate
{
    [self.locationManager stopMonitoringForRegion:_monitoredDeliveryRegion];
    _monitoredDeliveryRegion = nil;
    
}

- (void)checkNowForPresenceInRegion:(CLRegion *)region
{
    // for whatever reason, during testing this wasn't working when called immediately
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.locationManager requestStateForRegion:region];
    });
}

@end
