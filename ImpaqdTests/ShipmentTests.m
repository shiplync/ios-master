//
//  ShipmentTests.m
//  Impaqd
//
//  Created by Traansmission on 4/20/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "Shipment.h"
#import "HelperFunctions.h"
#import "LocationCoordinator.h"

@interface ShipmentTests : TRTestCase

@property (nonatomic) Shipment *target;
@property (nonatomic) NSDictionary *fixture;

@end

@implementation ShipmentTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSURL *fixtureURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"shipment" withExtension:@"json"];
    NSData *fixtureData = [NSData dataWithContentsOfURL:fixtureURL];
    self.fixture = [NSJSONSerialization JSONObjectWithData:fixtureData options:0 error:nil];
    self.target = [[Shipment alloc] initWithJSONAttributes:self.fixture];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.target = nil;
    self.fixture = nil;
    [super tearDown];
}

- (void)testPickUpAddressMinimum {
    NSString *expected = @"New York, NY  10010";
    NSString *actual = [self.target pickUpAddressMinimum];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testDeliveryAddressMinimum {
    NSString *expected = @"New York, NY  10010";
    NSString *actual = [self.target deliveryAddressMinimum];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testDeliveryStatusDescriptionIsApprovedForShipmentStatusPendingPickupDeliveryStatus {
    self.target.deliveryStatus = @(ShipmentStatusPendingPickup);
    XCTAssertEqualObjects(@"Approved", [self.target deliveryStatusDescription]);
}

- (void)testDeliveryStatusDescriptionIsPendingApprovalForShipmentStatusPendingApprovalDeliveryStatus {
    self.target.deliveryStatus = @(ShipmentStatusPendingApproval);
    XCTAssertEqualObjects(@"Pending Approval", [self.target deliveryStatusDescription]);
}

- (void)testDeliveryStatusDescriptionIsPendingApprovalForShipmentStatusPendingDeliveryDeliveryStatus {
    self.target.deliveryStatus = @(ShipmentStatusPendingDelivery);
    XCTAssertEqualObjects(@"Enroute", [self.target deliveryStatusDescription]);
}

- (void)testDeliveryStatusDescriptionForOtherDeliveryStatuses {
    ShipmentStatus status = arc4random_uniform(ShipmentStatusPendingApproval);
    while (status == ShipmentStatusPendingPickup || status == ShipmentStatusPendingApproval || status == ShipmentStatusPendingDelivery) {
        status = arc4random_uniform(ShipmentStatusPendingApproval);
    }
    self.target.deliveryStatus = @(status);
    XCTAssertEqualObjects(@"--", [self.target deliveryStatusDescription]);
}

- (void)testDeliveryApprovedIsTrueForShipmentStatusPendingPickup {
    self.target.deliveryStatus = @(ShipmentStatusPendingPickup);
    XCTAssertTrue(self.target.deliveryApproved);
}

- (void)testDeliveryApprovedIsFalseForShipmentStatusPendingApproval {
    self.target.deliveryStatus = @(ShipmentStatusPendingApproval);
    XCTAssertFalse(self.target.deliveryApproved);
}

- (void)testPickUpTimeDescriptionInvokesHelperFunctionWithPickUpTimeRangeStartAndPickupTimeZone {
    self.target.pickUpTimeRangeStart = [NSDate date];
    self.target.pickUpTimeZone = [NSTimeZone localTimeZone];
    id mockHelper = OCMClassMock([HelperFunctions class]);
    OCMStub([mockHelper sharedInstance]).andReturn(mockHelper);
    NSString *expected = self.randomSentence;
    OCMExpect([mockHelper getDateString:self.target.pickUpTimeRangeStart withTimeZone:self.target.pickupTz]).andReturn(expected);
    NSString *actual = [self.target pickUpTimeDescription];
    XCTAssertEqualObjects(expected, actual);
    OCMVerifyAll(mockHelper);
    [mockHelper stopMocking];
}

- (void)testDeliveryTimeDescriptionInvokesHelperFunctionWithDeliveryTimeRangeStartAndDeliveryTimeZone {
    self.target.deliveryTimeRangeStart = [NSDate date];
    self.target.deliveryTimeZone = [NSTimeZone localTimeZone];
    id mockHelper = OCMClassMock([HelperFunctions class]);
    OCMStub([mockHelper sharedInstance]).andReturn(mockHelper);
    NSString *expected = self.randomSentence;
    OCMExpect([mockHelper getDateString:self.target.deliveryTimeRangeStart withTimeZone:self.target.deliveryTz]).andReturn(expected);
    NSString *actual = [self.target deliveryTimeDescription];
    XCTAssertEqualObjects(expected, actual);
    OCMVerifyAll(mockHelper);
    [mockHelper stopMocking];
}

- (void)testPayoutDescriptionForPayoutUSDBetween0And999999 {
    NSInteger payoutUSD = arc4random_uniform(999999);
    self.target.payoutUSD = (NSDecimalNumber *)[NSDecimalNumber numberWithInteger:payoutUSD];
    NSString *expected = [NSNumberFormatter localizedStringFromNumber:self.target.payoutUSD numberStyle:NSNumberFormatterCurrencyStyle];
    NSString *actual = [self.target payoutDescription];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testPayoutDescriptionForPayoutLessThanZero {
    self.target.payoutUSD = (NSDecimalNumber *)@(-1);
    self.target.payoutUSDtext = self.randomSentence;
    NSString *actual = [self.target payoutDescription];
    XCTAssertEqualObjects(self.target.payoutUSDtext, actual);
}

- (void)testPayoutDescriptionForPayoutGreaterThan999999 {
    self.target.payoutUSD = (NSDecimalNumber *)@(999999 + 1);
    self.target.payoutUSDtext = self.randomSentence;
    NSString *actual = [self.target payoutDescription];
    XCTAssertEqualObjects(self.target.payoutUSDtext, actual);
}

- (void)testPickUpDistanceDescriptionUsesCurrentLocation {
    CLLocation *testLocation = self.randomLocation;
    id mockLocationCoordinator = OCMClassMock([LocationCoordinator class]);
    OCMStub([mockLocationCoordinator sharedInstance]).andReturn(mockLocationCoordinator);
    OCMStub([mockLocationCoordinator lastLocation]).andReturn(testLocation);
    
    CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude:[self.target.pickUpLatitude doubleValue] longitude:[self.target.pickUpLongitude doubleValue]];
    CLLocationDistance distance = [testLocation distanceFromLocation:pickupLocation];
    MKDistanceFormatter *formatter = [[MKDistanceFormatter alloc] init];
    formatter.units = MKDistanceFormatterUnitsImperial;
    
    NSString *distanceString = [formatter stringFromDistance:distance];
    NSString *expected = [NSString stringWithFormat:@"%@ away", distanceString];
    NSString *actual = [self.target pickUpDistanceDescription];
    XCTAssertEqualObjects(expected, actual);
    
    [mockLocationCoordinator stopMocking];
}

- (void)testPickUpDistanceDescriptionIfNoCurrentLocation {
    id mockLocationCoordinator = OCMClassMock([LocationCoordinator class]);
    OCMStub([mockLocationCoordinator sharedInstance]).andReturn(mockLocationCoordinator);
    OCMStub([mockLocationCoordinator lastLocation]).andReturn(nil);
    
    NSString *expected = @"--";
    NSString *actual = [self.target pickUpDistanceDescription];
    XCTAssertEqualObjects(expected, actual);
    
    [mockLocationCoordinator stopMocking];
}

- (void)testDeliveryDistanceDescriptionUsesCurrentLocation {
    CLLocation *testLocation = self.randomLocation;
    id mockLocationCoordinator = OCMClassMock([LocationCoordinator class]);
    OCMStub([mockLocationCoordinator sharedInstance]).andReturn(mockLocationCoordinator);
    OCMStub([mockLocationCoordinator lastLocation]).andReturn(testLocation);
    
    CLLocation *deliveryLocation = [[CLLocation alloc] initWithLatitude:[self.target.deliveryLatitude doubleValue] longitude:[self.target.deliveryLongitude doubleValue]];
    CLLocationDistance distance = [testLocation distanceFromLocation:deliveryLocation];
    MKDistanceFormatter *formatter = [[MKDistanceFormatter alloc] init];
    formatter.units = MKDistanceFormatterUnitsImperial;
    
    NSString *distanceString = [formatter stringFromDistance:distance];
    NSString *expected = [NSString stringWithFormat:@"%@ away", distanceString];
    NSString *actual = [self.target deliveryDistanceDescription];
    XCTAssertEqualObjects(expected, actual);
    
    [mockLocationCoordinator stopMocking];
}

- (void)testDeliveryDistanceDescriptionIfNoCurrentLocation {
    id mockLocationCoordinator = OCMClassMock([LocationCoordinator class]);
    OCMStub([mockLocationCoordinator sharedInstance]).andReturn(mockLocationCoordinator);
    OCMStub([mockLocationCoordinator lastLocation]).andReturn(nil);
    
    NSString *expected = @"--";
    NSString *actual = [self.target deliveryDistanceDescription];
    XCTAssertEqualObjects(expected, actual);
    
    [mockLocationCoordinator stopMocking];
}

@end
