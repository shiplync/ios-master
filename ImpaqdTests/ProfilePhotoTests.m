//
//  ProfilePhotoTests.m
//  Impaqd
//
//  Created by Traansmission on 5/7/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "ProfilePhoto.h"

@interface ProfilePhotoTests : TRTestCase

@property (nonatomic) ProfilePhoto *target;
@property (nonatomic) NSDictionary *fixture;

@end

@implementation ProfilePhotoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSURL *fixtureURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"profile_photo" withExtension:@"json"];
    NSData *fixtureData = [NSData dataWithContentsOfURL:fixtureURL];
    self.fixture = [NSJSONSerialization JSONObjectWithData:fixtureData options:0 error:nil];
    self.target = [MTLJSONAdapter modelOfClass:[ProfilePhoto class] fromJSONDictionary:self.fixture error:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.target = nil;
    self.fixture = nil;
    [super tearDown];
}

- (void)testInitialization {
    XCTAssertTrue([self.target isKindOfClass:[ProfilePhoto class]]);
}

- (void)testJSONReverseTransformation {
    NSDictionary *jsonTarget = [MTLJSONAdapter JSONDictionaryFromModel:self.target error:nil];
    XCTAssertEqualObjects(self.fixture[@"id"], jsonTarget[@"id"]);
    XCTAssertEqualObjects(self.fixture[@"file_url"], jsonTarget[@"file_url"]);
    XCTAssertEqualObjects(self.fixture[@"path"], jsonTarget[@"path"]);
    XCTAssertEqualObjects(self.fixture[@"uuid_value"], [jsonTarget[@"uuid_value"] lowercaseString]);
    XCTAssertEqualObjects(self.fixture[@"created_at"], jsonTarget[@"created_at"]);
    XCTAssertEqualObjects(self.fixture[@"updated_at"], jsonTarget[@"updated_at"]);
}

@end
