//
//  LocationCoordinatorTests.m
//  Impaqd
//
//  Created by Traansmission on 5/26/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "LocationCoordinator.h"

@interface LocationCoordinatorTests : TRTestCase

@property (nonatomic) LocationCoordinator *target;
@property (nonatomic) id mockLocationManager;

@end

@implementation LocationCoordinatorTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.mockLocationManager = OCMClassMock([CLLocationManager class]);
    self.target = [[LocationCoordinator alloc] initWithLocationManager:self.mockLocationManager];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.target = nil;
    self.mockLocationManager = nil;
    [super tearDown];
}


#pragma mark - KVO Class Method Override Tests

- (void)testAutomaticallyNotifiesObserversForKeyAuthorizationStatusReturnNO {
    XCTAssertFalse([LocationCoordinator automaticallyNotifiesObserversForKey:@"authorizationStatus"]);
}


#pragma mark - Initialization Tests

- (void)testInitialization {
    XCTAssert([self.target isKindOfClass:[LocationCoordinator class]]);
}

- (void)testLocationCoordinatorIsLocationManagerDelegate {
    OCMStub([self.mockLocationManager setDelegate:[OCMArg checkWithBlock:^(id value) {
        return [(NSObject *)value conformsToProtocol:@protocol(CLLocationManagerDelegate)];
    }]]);
    self.target = [[LocationCoordinator alloc] initWithLocationManager:self.mockLocationManager];
    OCMVerifyAll(self.mockLocationManager);
}

- (void)testAuthorizationStatusInitializesWithCLLocationManagerAuthorizationStatus {
    NSInteger expected = arc4random_uniform(BUFSIZ);
    OCMStub([self.mockLocationManager authorizationStatus]).andReturn(expected);
    self.target = [[LocationCoordinator alloc] initWithLocationManager:self.mockLocationManager];
    NSInteger actual = self.target.authorizationStatus;
    XCTAssertEqual(expected, actual);
}


#pragma mark - Property Override Tests

#pragma mark - @enabledWhileInUse Tests

- (void)testEnabledWhileInUseReturnsNOIfCLLocationManagerLocationServicesEnabledIsNO {
    OCMStub(ClassMethod([self.mockLocationManager locationServicesEnabled])).andReturn(NO);
    XCTAssertFalse([self.target isEnabledWhileInUse]);
    [self.mockLocationManager stopMocking];
}

- (void)testEnabledWhileInUseYESIfAuthorizationStatusAuthorizedWhenInUse {
    OCMStub(ClassMethod([self.mockLocationManager locationServicesEnabled])).andReturn(YES);
    id mockTarget = OCMPartialMock(self.target);
    OCMStub([mockTarget authorizationStatus]).andReturn(kCLAuthorizationStatusAuthorizedWhenInUse);
    XCTAssertTrue([mockTarget isEnabledWhileInUse]);
    [mockTarget stopMocking];
}

- (void)testEnabledWhileInUseYESIfAuthorizationStatusAuthorizedAlways {
    OCMStub(ClassMethod([self.mockLocationManager locationServicesEnabled])).andReturn(YES);
    id mockTarget = OCMPartialMock(self.target);
    OCMStub([mockTarget authorizationStatus]).andReturn(kCLAuthorizationStatusAuthorizedAlways);
    XCTAssertTrue([mockTarget isEnabledWhileInUse]);
    [mockTarget stopMocking];
}

- (void)testEnabledWhileInUserIfAuthorizationStatusNotAuthorized {
    CLAuthorizationStatus status = arc4random_uniform(kCLAuthorizationStatusAuthorized); // will be less than kCLAuthorizationStatusAuthorized
    id mockTarget = OCMPartialMock(self.target);
    OCMStub([mockTarget authorizationStatus]).andReturn(status);
    XCTAssertFalse([mockTarget isEnabledWhileInUse]);
    [mockTarget stopMocking];
}


#pragma mark - -startMonitoring Tests

- (void)testStartMonitoringInvokesLocationManagerStartMonitoringSignificantLocationChanges {
    [self.target startMonitoring];
    OCMVerify([self.mockLocationManager startMonitoringSignificantLocationChanges]);
}

#pragma mark - stopMonitoring Tests

- (void)testStopMonitoringInvokesLocationManagerStopMonitoringSignificanytLocationChanges {
    [self.target stopMonitoring];
    OCMVerify([self.mockLocationManager stopMonitoringSignificantLocationChanges]);
}

#pragma mark - -monitorRegionWithCoordinate: Tests

- (void)testMonitorRegionWithCoordinateStartsMonitoringForCircularRegion {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0.0f, 0.0f);
    [self.target monitorRegionWithCoordinate:coordinate];
    OCMVerify([self.mockLocationManager startMonitoringForRegion:[OCMArg isKindOfClass:[CLCircularRegion class]]]);
}

- (void)testMonitorRegionWithCoordinateStopsMonitorIfRegionExists {
    // Set region view CLLocationManagerDelegate method
    CLRegion *region = [[CLRegion alloc] init];
    [self.target locationManager:self.mockLocationManager didStartMonitoringForRegion:region];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0.0f, 0.0f);
    [self.target monitorRegionWithCoordinate:coordinate];
    OCMVerify([self.mockLocationManager stopMonitoringForRegion:region]);
}


#pragma mark - CLLocationManagerDelegate Methods Tests

#pragma mark - -locationManager:didStartMonitoringForRegion: Tests

- (void)testLocationManagerDidStartMonitoringForRegionSetsRegionProperty {
    XCTAssertNil(self.target.region);
    CLRegion *expected = [[CLRegion alloc] init];
    [self.target locationManager:self.mockLocationManager didStartMonitoringForRegion:expected];
    CLRegion *actual = self.target.region;
    XCTAssertEqualObjects(expected, actual);
}

#pragma mark - -locationManager:didChangeAuthorizationStatus: Tests

- (void)testLocationManagerDidChangeAuthorizationStatusUpdatesProperty {
    CLAuthorizationStatus expected = (CLAuthorizationStatus)arc4random_uniform(BUFSIZ);
    XCTAssertNotEqual(self.target.authorizationStatus, expected);
    [self.target locationManager:self.mockLocationManager didChangeAuthorizationStatus:expected];
    XCTAssertEqual(self.target.authorizationStatus, expected);
}

@end
