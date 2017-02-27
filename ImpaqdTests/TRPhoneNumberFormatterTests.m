//
//  TRPhoneNumberFormatterTests.m
//  Impaqd
//
//  Created by Traansmission on 5/20/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "TRPhoneNumberFormatter.h"

@interface TRPhoneNumberFormatterTests : TRTestCase

@property (nonatomic) TRPhoneNumberFormatter *target;
@property (nonatomic) NBPhoneNumber *phoneNumber;

@end

@implementation TRPhoneNumberFormatterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    self.phoneNumber = [phoneUtil parse:@"212-555-1212" defaultRegion:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] error:nil];
    self.target = [TRPhoneNumberFormatter defaultFormatter];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.target = nil;
    [super tearDown];
}

- (void)testInitialization {
    XCTAssert([self.target isKindOfClass:[TRPhoneNumberFormatter class]]);
}

#pragma mark - -stringForObjectValue: Tests

- (void)testStringForObjectValueReturnsNILForString {
    XCTAssertNil([self.target stringForObjectValue:@"212-555-1212"]);
}

- (void)testStringForObjectValueWithPhoneNumberStyleNational {
    [self.target setPhoneNumberStyle:PhoneNumberFormatterStyleNational];
    NSString *expected = @"(212) 555-1212";
    NSString *actual = [self.target stringForObjectValue:self.phoneNumber];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testStringForObjectValueWithPhoneNumberStyleInternational {
    [self.target setPhoneNumberStyle:PhoneNumberFormatterStyleInternational];
    NSString *expected = @"+1 212-555-1212";
    NSString *actual = [self.target stringForObjectValue:self.phoneNumber];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testStringForObjectValueWithPhoneNumberStyleRFC3966 {
    [self.target setPhoneNumberStyle:PhoneNumberFormatterStyleRFC3966];
    NSString *expected = @"tel:+1-212-555-1212";
    NSString *actual = [self.target stringForObjectValue:self.phoneNumber];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testStringForObjectValueWithPhoneNumberStyleE164 {
    [self.target setPhoneNumberStyle:PhoneNumberFormatterStyleE164];
    NSString *expected = @"+12125551212";
    NSString *actual = [self.target stringForObjectValue:self.phoneNumber];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testStringForObjectValueWithPhoneNumberStyleNationalNumbersOnly {
    [self.target setPhoneNumberStyle:PhoneNumberFormatterStyleNationalNumbersOnly];
    NSString *expected = @"2125551212";
    NSString *actual = [self.target stringForObjectValue:self.phoneNumber];
    XCTAssertEqualObjects(expected, actual);
}

#pragma mark - -getObjectValue:forString:errorDescription: Tests

- (void)testGetObjectValueForStringErrorDescriptionForPhoneNumberFormatterStyleNational {
    [self.target setPhoneNumberStyle:PhoneNumberFormatterStyleNational];
    NSString *string = [self.target stringForObjectValue:self.phoneNumber];
    NBPhoneNumber *objectValue;
    XCTAssertTrue([self.target getObjectValue:&objectValue forString:string errorDescription:nil]);
    XCTAssertEqualObjects(self.phoneNumber, objectValue);
}

- (void)testGetObjectValueForStringErrorDescriptionForPhoneNumberFormatterStyleInterNational {
    [self.target setPhoneNumberStyle:PhoneNumberFormatterStyleInternational];
    NSString *string = [self.target stringForObjectValue:self.phoneNumber];
    NBPhoneNumber *objectValue;
    XCTAssertTrue([self.target getObjectValue:&objectValue forString:string errorDescription:nil]);
    XCTAssertEqualObjects(self.phoneNumber, objectValue);
}

- (void)testGetObjectValueForStringErrorDescriptionForPhoneNumberFormatterStyleRFC3699 {
    [self.target setPhoneNumberStyle:PhoneNumberFormatterStyleRFC3966];
    NSString *string = [self.target stringForObjectValue:self.phoneNumber];
    NBPhoneNumber *objectValue;
    XCTAssertTrue([self.target getObjectValue:&objectValue forString:string errorDescription:nil]);
    XCTAssertEqualObjects(self.phoneNumber, objectValue);
}

- (void)testGetObjectValueForStringErrorDescriptionForPhoneNumberFormatterStyleE164 {
    [self.target setPhoneNumberStyle:PhoneNumberFormatterStyleE164];
    NSString *string = [self.target stringForObjectValue:self.phoneNumber];
    NBPhoneNumber *objectValue;
    XCTAssertTrue([self.target getObjectValue:&objectValue forString:string errorDescription:nil]);
    XCTAssertEqualObjects(self.phoneNumber, objectValue);
}

#pragma mark - -stringFromPhoneNumber:phoneNumberStyle: Tests

- (void)testStringFromPhoneNumberPhoneNumberStyleDoesNotChangePhoneNumberFormatterStyle {
    enum PhoneNumberFormatterStyle expected = PhoneNumberFormatterStyleE164;
    [self.target setPhoneNumberStyle:expected];
    [self.target stringFromPhoneNumber:self.phoneNumber phoneNumberStyle:PhoneNumberFormatterStyleInternational];
    enum PhoneNumberFormatterStyle actual = [self.target phoneNumberStyle];
    XCTAssertEqual(expected, actual);
    
}

@end
