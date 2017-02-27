//
//  AvailableShipmentSearchParameterTests.m
//  Impaqd
//
//  Created by Traansmission on 4/17/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "AvailableShipmentSearchParameters.h"
#import "Shipment.h"

@interface AvailableShipmentSearchParameterTests : TRTestCase

@property (nonatomic) AvailableShipmentSearchParameters *target;

@end

@implementation AvailableShipmentSearchParameterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.target = [[AvailableShipmentSearchParameters alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.target = nil;
    [super tearDown];
}

- (void)testInitialization {
    XCTAssert([self.target isKindOfClass:[AvailableShipmentSearchParameters class]]);
}

#pragma mark - -updateTimeParameters Tests

- (void)testUpdateTimeParametersSetsPickUpTimeIfNIL {
    XCTAssertNil(self.target.pickUpTime);
    [self.target updateTimeParameters];
    XCTAssertNotNil(self.target.pickUpTime);
    XCTAssertTrue([self.target.pickUpTime isKindOfClass:[NSDate class]]);
}

- (void)testUpdateTimeParametersSetsPickUpTimeIfInPast {
    id mockPickUpTime = OCMClassMock([NSDate class]);
    OCMStub([mockPickUpTime timeIntervalSinceNow]).andReturn((NSTimeInterval)-1.0);
    
    id mockTarget = OCMPartialMock(self.target);
    OCMStub([mockTarget pickUpTime]).andReturn(mockPickUpTime);

    OCMExpect([mockTarget setPickUpTime:[OCMArg isKindOfClass:[NSDate class]]]);
    [mockTarget updateTimeParameters];
    OCMVerifyAll(mockTarget);
    
    [mockTarget stopMocking];
}

- (void)testUpdateTimeParametersSetsDeliveryTimeIfNIL {
    XCTAssertNil(self.target.deliveryTime);
    [self.target updateTimeParameters];
    XCTAssertNotNil(self.target.deliveryTime);
    XCTAssertTrue([self.target.deliveryTime isKindOfClass:[NSDate class]]);
}

- (void)testUpdateTimeParameterUpdatesDeliverTimeIfLessThanSixHoursGreaterThanPickUpTime {
    NSDate *now = [NSDate date];
    NSInteger hours = (NSInteger)arc4random_uniform(5) + 1;
    NSDate *before = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:hours toDate:self.target.pickUpTime options:kNilOptions];
    
    self.target.pickUpTime = now;
    self.target.deliveryTime = before;
    [self.target updateTimeParameters];
    XCTAssertNotEqualObjects(before, self.target.deliveryTime);
}

#pragma mark - -toQueryParameters methods

- (void)testToQueryParametersSetsUnclaimedOnlyToTrue {
    NSDictionary *queryParams = [self.target toQueryParameters];
    NSString *expected = @"True";
    NSString *actual = queryParams[@"unclaimed_only"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testToQueryParametersSetsMaxTripDistance {
    NSDictionary *queryParams = [self.target toQueryParameters];
    CLLocationDistance expected = self.target.maximumTripDistance;
    CLLocationDistance actual = [queryParams[@"max_trip"] doubleValue];
    XCTAssertEqual(expected, actual);
}

- (void)testToQueryParametersSetsLocalSearchRadius {
    NSDictionary *queryParams = [self.target toQueryParameters];
    CLLocationDistance expected = self.target.searchRadius;
    CLLocationDistance actual = [queryParams[@"local_search_radius"] doubleValue];
    XCTAssertEqual(expected, actual);
}

- (void)testToQueryParametersSetsEarliestPickUpTimeIfNotNIL {
    self.target.pickUpTime = [NSDate dateWithTimeIntervalSinceReferenceDate:0.0];
    NSDictionary *queryParams = [self.target toQueryParameters];
    NSString *expected = @"2000-12-31T19:00:00-0500";
    NSString *actual = queryParams[@"earliest_pick_up_time"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testToQueryParametersSetsVehicleTypeIfNotNIL {
    VehicleType vehicleType = (VehicleType)(arc4random_uniform(VehicleTypeVan) + 1);
    self.target.vehicleType = vehicleType;
    NSDictionary *queryParams = [self.target toQueryParameters];
    NSString *expected = [NSNumberFromVehicleType(self.target.vehicleType) stringValue];
    NSString *actual = queryParams[@"vehicle_type"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testToQueryParametersSetsOrderingForProximity {
    self.target.orderingType = ShipmentFetchOrderingTypeByProximity;
    NSDictionary *queryParams = [self.target toQueryParameters];
    NSString *expected = @"shipper_proximity";
    NSString *actual = queryParams[@"ordering"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testToQueryParametersSetsOrderingForPickUpTime {
    self.target.orderingType = ShipmentFetchOrderingTypeByPickUpTime;
    NSDictionary *queryParams = [self.target toQueryParameters];
    NSString *expected = @"pick_up_time_range_start";
    NSString *actual = queryParams[@"ordering"];
    XCTAssertEqualObjects(expected, actual);
}

@end
