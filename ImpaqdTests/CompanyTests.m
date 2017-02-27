//
//  CompanyTests.m
//  Impaqd
//
//  Created by Traansmission on 5/6/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "Company.h"

@interface CompanyTests : TRTestCase

@property (nonatomic) Company *target;
@property (nonatomic) NSDictionary *fixture;

@end

@implementation CompanyTests

- (void)setUp {
    [super setUp];
    NSURL *fixtureURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"company" withExtension:@"json"];
    NSData *fixtureData = [NSData dataWithContentsOfURL:fixtureURL];
    self.fixture = [NSJSONSerialization JSONObjectWithData:fixtureData options:0 error:nil];
    self.target = [MTLJSONAdapter modelOfClass:[Company class] fromJSONDictionary:self.fixture error:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.target = nil;
    self.fixture = nil;
    [super tearDown];
}

- (void)testInitialization {
    XCTAssertTrue([self.target isKindOfClass:[Company class]]);
}

- (void)testJSONReverseTransformation {
    NSDictionary *jsonTarget = [MTLJSONAdapter JSONDictionaryFromModel:self.target error:nil];
    XCTAssertEqualObjects(self.fixture[@"id"], jsonTarget[@"id"]);
    XCTAssertEqualObjects(self.fixture[@"company_name"], jsonTarget[@"company_name"]);
    XCTAssertEqualObjects(self.fixture[@"dot"], jsonTarget[@"dot"]);
    XCTAssertEqualObjects(self.fixture[@"is_fleet"], jsonTarget[@"is_fleet"]);
    XCTAssertEqualObjects(self.fixture[@"max_requests"], jsonTarget[@"max_requests"]);
    XCTAssertEqualObjects(self.fixture[@"rejected"], jsonTarget[@"rejected"]);
    XCTAssertEqualObjects(self.fixture[@"verified"], jsonTarget[@"verified"]);
    XCTAssertEqualObjects(self.fixture[@"created_at"], jsonTarget[@"created_at"]);
    XCTAssertEqualObjects(self.fixture[@"updated_at"], jsonTarget[@"updated_at"]);
}

@end
