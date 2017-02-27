//
//  CarrierTests.m
//  Impaqd
//
//  Created by Traansmission on 5/14/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "Carrier.h"
#import "AccountProtocol.h"
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>

@interface CarrierTests : TRTestCase

@property (nonatomic) Carrier *target;
@property (nonatomic) NSDictionary *fixture;

@end

@implementation CarrierTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSURL *fixtureURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"carriers_self_drivers_nested" withExtension:@"json"];
    NSData *fixtureData = [NSData dataWithContentsOfURL:fixtureURL];
    self.fixture = [NSJSONSerialization JSONObjectWithData:fixtureData options:0 error:nil];
    self.target = [MTLJSONAdapter modelOfClass:[Carrier class] fromJSONDictionary:self.fixture error:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.target = nil;
    self.fixture = nil;
    [super tearDown];
}

- (void)testInitialization {
    XCTAssertTrue([self.target isKindOfClass:[Carrier class]]);
    XCTAssertTrue([self.target conformsToProtocol:@protocol(AccountProtocol)]);
}

- (void)testPhoneNumberInitialization {
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    XCTAssertTrue([phoneUtil isValidNumber:self.target.phoneNumber]);
    NSString *expected = @"+12125551212";
    NSString *actual = [phoneUtil format:self.target.phoneNumber numberFormat:NBEPhoneNumberFormatE164 error:nil];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testVehicleTypeInitialization {
    enum VehicleType expected = VehicleTypeFromNSNumber(self.fixture[@"vehicle_type"]);
    enum VehicleType actual = self.target.vehicleType;
    XCTAssertEqual(expected, actual);
}

- (void)testCompanyInitialization {
    XCTAssertTrue([self.target.company isKindOfClass:[Company class]]);
}

- (void)testProfilePhotoInitialization {
    XCTAssertTrue([self.target.profilePhoto isKindOfClass:[ProfilePhoto class]]);
}

- (void)testJSONReverseTransformation {
    NSDictionary *jsonTarget = [MTLJSONAdapter JSONDictionaryFromModel:self.target error:nil];
    XCTAssertEqualObjects(self.fixture[@"id"], jsonTarget[@"id"]);
    XCTAssertEqualObjects(self.fixture[@"user"], jsonTarget[@"user"]);
    XCTAssertEqualObjects(self.fixture[@"email"], jsonTarget[@"email"]);
    XCTAssertEqualObjects(self.fixture[@"first_name"], jsonTarget[@"first_name"]);
    XCTAssertEqualObjects(self.fixture[@"last_name"], jsonTarget[@"last_name"]);
    XCTAssertEqualObjects(self.fixture[@"vehicle_type"], jsonTarget[@"vehicle_type"]);
    XCTAssertEqualObjects(self.fixture[@"created_at"], jsonTarget[@"created_at"]);
    XCTAssertEqualObjects(self.fixture[@"updated_at"], jsonTarget[@"updated_at"]);
    
    // Phone Number formatting
    XCTAssertEqualObjects(@"+12125551212", jsonTarget[@"phone"]);

}

@end
