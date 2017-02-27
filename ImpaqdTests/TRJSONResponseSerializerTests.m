//
//  TRJSONResponseSerializerTests.m
//  Impaqd
//
//  Created by Traansmission on 4/3/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "TRJSONResponseSerializer.h"

@interface AFJSONResponseSerializer (TestExtension)
- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error;
@end

@implementation AFJSONResponseSerializer (TestExtension)
- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    *error = [NSError errorWithDomain:(NSString *)TRTestErrorDomain code:NSIntegerMax userInfo:nil];
    return nil;
}
@end

@interface TRJSONResponseSerializerTests : TRTestCase

@property (nonatomic) TRJSONResponseSerializer *target;

@end

@implementation TRJSONResponseSerializerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.target = [TRJSONResponseSerializer serializer];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.target = nil;
    [super tearDown];
}

- (void)testInitialization {
    XCTAssertTrue([self.target isKindOfClass:[TRJSONResponseSerializer class]]);
    XCTAssertTrue([self.target isKindOfClass:[AFJSONResponseSerializer class]]);
}

- (void)testResponseObjectForResponseDataErrorPopulatesUserInfoIfJSONData {
    NSURLResponse *response = [[NSURLResponse alloc] init];
    NSDictionary *jsonData = @{ @"json" : @"data" };
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonData options:9 error:nil];
    NSError *error;
    
    [self.target responseObjectForResponse:response data:data error:&error];

    XCTAssertNotNil(error);
    XCTAssertNotNil(error.userInfo[TRJSONResponseSerializerKey]);
    XCTAssertEqualObjects(jsonData, error.userInfo[TRJSONResponseSerializerKey]);
}

- (void)testResponseObjectForResponseDataErrorDoesNotPopulatesUserInfoIfDataNotJSONSerializable {
    NSURLResponse *response = [[NSURLResponse alloc] init];
    NSData *data = [NSData data];
    NSError *error;
    
    [self.target responseObjectForResponse:response data:data error:&error];
    
    XCTAssertNotNil(error);
    XCTAssertNil(error.userInfo[TRJSONResponseSerializerKey]);
}

@end
