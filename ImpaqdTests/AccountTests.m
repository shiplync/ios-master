//
//  AccountTests.m
//  Impaqd
//
//  Created by Traansmission on 4/8/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "Account.h"

@interface AccountTests : TRTestCase

@property (nonatomic) Account *target;

@end

@implementation AccountTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.target = [[Account alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.target = nil;
    [super tearDown];
}

- (void)_setUpAccount {
    NSString *phone = [MBFakerPhoneNumber phoneNumber];
    NBPhoneNumber *phoneNumber = [[TRPhoneNumberFormatter defaultFormatter] phoneNumberFromString:phone];
    NSString *firstName = [MBFakerName firstName];
    NSString *lastName = [MBFakerName lastName];
    
    self.target.emailAddress = [MBFakerInternet email];
    self.target.password = [MBFakerLorem word];
    self.target.phoneNumber = phoneNumber;
    self.target.firstName = firstName;
    self.target.lastName = lastName;
    
    self.target.companyName = [MBFakerCompany name];
    self.target.licenseNumber = @"1234567";

//    self.target.phoneNumber = phone;
//    self.target.firstName = firstName;
//    self.target.lastName = lastName;
}

- (void)testInitialization {
    XCTAssertTrue([self.target isKindOfClass:[Account class]]);
    XCTAssertTrue([self.target conformsToProtocol:@protocol(AccountProtocol)]);
}

#pragma mark - NSCoding Tests

- (void)testEncodingAndDecoding {
    NSData *targetData = [NSKeyedArchiver archivedDataWithRootObject:self.target];
    Account *decodedAccount = [NSKeyedUnarchiver unarchiveObjectWithData:targetData];
    XCTAssertEqualObjects(self.target.serverId, decodedAccount.serverId);
    XCTAssertEqualObjects(self.target.emailAddress, decodedAccount.emailAddress);
    XCTAssertEqualObjects(self.target.password, decodedAccount.password);
    XCTAssertEqualObjects(self.target.companyName, decodedAccount.companyName);
    XCTAssertEqualObjects(self.target.firstName, decodedAccount.firstName);
    XCTAssertEqualObjects(self.target.lastName, decodedAccount.lastName);
    XCTAssertEqualObjects(self.target.phoneNumber, decodedAccount.phoneNumber);
    XCTAssertEqualObjects(self.target.licenseNumber, decodedAccount.licenseNumber);
    XCTAssertEqualObjects(self.target.photoBase64, decodedAccount.photoBase64);
    XCTAssertEqualObjects(self.target.photo, decodedAccount.photo);
    
    XCTAssertEqual(self.target.isServerVerified, decodedAccount.isServerVerified);
    XCTAssertEqual(self.target.vehicleType, decodedAccount.vehicleType);
}

#pragma mark - -registrationParameters Tests

- (void)testRegistrationParametersSetsUserDictionary {
    [self _setUpAccount];
    NSDictionary *parameters = [self.target registrationParameters];
    XCTAssertNotNil(parameters[@"user"]);
    XCTAssertEqualObjects(parameters[@"user"][@"email"], self.target.emailAddress);
    XCTAssertEqualObjects(parameters[@"user"][@"password"], self.target.password);
    XCTAssertEqualObjects(parameters[@"user"][@"phone"], self.target.phoneNumberE164);
    XCTAssertEqualObjects(parameters[@"user"][@"first_name"], self.target.firstName);
    XCTAssertEqualObjects(parameters[@"user"][@"last_name"], self.target.lastName);
}

- (void)testRegistrationParametersSetsCompanyDictionary {
    [self _setUpAccount];
    NSDictionary *parameters = [self.target registrationParameters];
    XCTAssertNotNil(parameters[@"company"]);
    XCTAssertEqualObjects(parameters[@"company"][@"company_name"], self.target.companyName);
    XCTAssertEqualObjects(parameters[@"company"][@"dot"], self.target.licenseNumber);
    XCTAssertEqualObjects(parameters[@"company"][@"is_fleet"], @(NO));
}

- (void)testRegistrationParametersSetsCarrierDriverDictionary {
    [self _setUpAccount];
    NSDictionary *parameters = [self.target registrationParameters];
    XCTAssertNotNil(parameters[@"carrier_driver"]);
    XCTAssertNotNil(parameters[@"carrier_driver"][@"vehicle_type"]);
    XCTAssertEqualObjects(parameters[@"carrier_driver"][@"phone"], self.target.phoneNumberE164);
    XCTAssertEqualObjects(parameters[@"carrier_driver"][@"first_name"], self.target.firstName);
    XCTAssertEqualObjects(parameters[@"carrier_driver"][@"last_name"], self.target.lastName);
}

@end
