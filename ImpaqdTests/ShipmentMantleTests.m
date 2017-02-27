//
//  ShipmentMantleTests.m
//  Impaqd
//
//  Created by Traansmission on 6/10/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "Shipment.h"
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>

@interface ShipmentMantleTests : TRTestCase

@property (nonatomic) Shipment *target;
@property (nonatomic) NSDictionary *fixture;

@end

@implementation ShipmentMantleTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSURL *fixtureURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"shipment" withExtension:@"json"];
    NSData *fixtureData = [NSData dataWithContentsOfURL:fixtureURL];
    self.fixture = [NSJSONSerialization JSONObjectWithData:fixtureData options:0 error:nil];
    NSError *error;
    self.target = [MTLJSONAdapter modelOfClass:[Shipment class] fromJSONDictionary:self.fixture error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.target = nil;
    self.fixture = nil;
    [super tearDown];
}

- (void)testInitialization {
    XCTAssertTrue([self.target isKindOfClass:[Shipment class]]);
}

- (void)testShipperPhoneNumberInitialization {
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    XCTAssertTrue([phoneUtil isValidNumber:self.target.shipperPhoneNumber]);
    NSString *expected = @"+12125551212";
    NSString *actual = [phoneUtil format:self.target.shipperPhoneNumber numberFormat:NBEPhoneNumberFormatE164 error:nil];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testReceiverPhoneNumberInitialization {
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    XCTAssertTrue([phoneUtil isValidNumber:self.target.receiverPhoneNumber]);
    NSString *expected = @"+12125551213";
    NSString *actual = [phoneUtil format:self.target.receiverPhoneNumber numberFormat:NBEPhoneNumberFormatE164 error:nil];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testPickUpTimeRangeStartInitialization {
    NSString *dateString = self.fixture[@"pick_up_time_range_start"];
    NSDate *expected = [[TRMTLModel dateFormatter] dateFromString:dateString];
    NSDate *actual = self.target.pickUpTimeRangeStart;
    XCTAssertEqualObjects(expected, actual);
}

- (void)testPickUpTimeRangeEndInitialization {
    NSString *dateString = self.fixture[@"pick_up_time_range_end"];
    NSDate *expected = [[TRMTLModel dateFormatter] dateFromString:dateString];
    NSDate *actual = self.target.pickUpTimeRangeEnd;
    XCTAssertEqualObjects(expected, actual);
}

- (void)testPickUpTimeZoneInitialzation {
    NSString *tzString = self.fixture[@"pick_up_tz"];
    NSDate *expected = [NSTimeZone timeZoneWithName:tzString];
    NSDate *actual = self.target.pickUpTimeZone;
    XCTAssertEqualObjects(expected, actual);
}

- (void)testDeliveryTimeRangeStartInitialization {
    NSString *dateString = self.fixture[@"delivery_time_range_start"];
    NSDate *expected = [[TRMTLModel dateFormatter] dateFromString:dateString];
    NSDate *actual = self.target.deliveryTimeRangeStart;
    XCTAssertEqualObjects(expected, actual);
}

- (void)testDeliveryTimeRangeEndInitialization {
    NSString *dateString = self.fixture[@"delivery_time_range_end"];
    NSDate *expected = [[TRMTLModel dateFormatter] dateFromString:dateString];
    NSDate *actual = self.target.deliveryTimeRangeEnd;
    XCTAssertEqualObjects(expected, actual);
}

- (void)testDeliveryTimeZoneInitialzation {
    NSString *tzString = self.fixture[@"delivery_tz"];
    NSDate *expected = [NSTimeZone timeZoneWithName:tzString];
    NSDate *actual = self.target.deliveryTimeZone;
    XCTAssertEqualObjects(expected, actual);
}


#pragma mark - Derived Property Tests

#pragma mark - @serverId Tests

- (void)testServerIdIsStringValueOfTraansmissionId {
    XCTAssertNotNil(self.target.traansmissionId);
    NSString *expected = [self.target.traansmissionId stringValue];
    NSString *actual = self.target.serverId;
    XCTAssertEqualObjects(expected, actual);
}

#pragma mark - @shipperPhone Tests

- (void)testShipperPhoneIsTRPhoneNumberFormatterStringForPhoneNumber {
    XCTAssertNotNil(self.target.shipperPhoneNumber);
    NSString *expected = [[TRPhoneNumberFormatter defaultFormatter] stringFromPhoneNumber:self.target.shipperPhoneNumber];
    NSString *actual = self.target.shipperPhone;
    XCTAssertEqualObjects(expected, actual);
}

#pragma mark - @receiverPhone Tests

- (void)testReceiverPhoneIsTRPhoneNumberFormatterStringForPhoneNumber {
    XCTAssertNotNil(self.target.receiverPhoneNumber);
    NSString *expected = [[TRPhoneNumberFormatter defaultFormatter] stringFromPhoneNumber:self.target.receiverPhoneNumber];
    NSString *actual = self.target.receiverPhone;
    XCTAssertEqualObjects(expected, actual);
}

#pragma mark - @pickupTz Tests

- (void)testPickupTzIsPickUpTimeZone {
    XCTAssertEqualObjects(self.target.pickUpTimeZone, self.target.pickupTz);
}

#pragma mark - @deliveryTz Tests

- (void)testDeliveryTzIsDeliveryTimeZone {
    XCTAssertEqualObjects(self.target.deliveryTimeZone, self.target.deliveryTz);
}

#pragma mark - @pickUpCoordinate Tests

- (void)testPickUpCoordinateDerivedFromPickUpLatitudeAndLongitude {
    XCTAssertEqual([self.target.pickUpLatitude doubleValue], self.target.pickUpCoordinate.latitude);
    XCTAssertEqual([self.target.pickUpLongitude doubleValue], self.target.pickUpCoordinate.longitude);
}

#pragma mark - @deliveryCoordinate Tests

- (void)testDeliveryCoordinateDerivedFromDeliveryLatitudeAndLongitude {
    XCTAssertEqual([self.target.deliveryLatitude doubleValue], self.target.deliveryCoordinate.latitude);
    XCTAssertEqual([self.target.deliveryLongitude doubleValue], self.target.deliveryCoordinate.longitude);
}

@end
