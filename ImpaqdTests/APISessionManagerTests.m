//
//  APISessionManagerTests.m
//  Impaqd
//
//  Created by Traansmission on 4/8/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "APISessionManager.h"
#import "TRJSONResponseSerializer.h"
#import "Shipment.h"
#import "TraansmissionKit.h"

@interface APISessionManager (TestExtensions)

- (AFJSONRequestSerializer *)unauthorizedRequestSerializer;
- (AFJSONRequestSerializer *)authorizedRequestSerializer;
- (AFJSONRequestSerializer *)geoAuthorizedRequestSerializer;

@end


@interface APISessionManagerTests : TRTestCase

@property (nonatomic) APISessionManager *target;
@property (nonatomic) id mockTarget;

@end

@implementation APISessionManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSURL *url = [NSURL URLWithString:@"http://example.com/"];
    self.target = [[APISessionManager alloc] initWithBaseURL:url];
    self.mockTarget = OCMPartialMock(self.target);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.mockTarget stopMocking];
    self.target = nil;
    [super tearDown];
}

#pragma mark - Initialization Tests

- (void)testInitialization {
    XCTAssertTrue([self.target isMemberOfClass:[APISessionManager class]]);
    XCTAssertTrue([self.target isKindOfClass:[AFHTTPSessionManager class]]);
}

- (void)testInitSetsResponseSerializerToTRJSONResponseSerializerInstance {
    XCTAssertTrue([self.target.responseSerializer isMemberOfClass:[TRJSONResponseSerializer class]]);
}

#pragma mark - -successBlockWithCompletion: Tests

- (void)testSuccessBlockWithCompletionInvokesCompletion {
    __block NSURLSessionTask *actualTask = nil;
    __block id actualResponseObject = nil;
    APISessionSuccessBlock testCompletion = ^(NSURLSessionTask *task, id responseObject) {
        actualTask = task;
        actualResponseObject = responseObject;
    };
    
    APISessionSuccessBlock testBlock = [self.target successBlockWithCompletion:testCompletion];
    NSURLSessionDataTask *expectedTask = [[NSURLSessionDataTask alloc] init];
    NSObject *expectedResponseObject = [[NSObject alloc] init];
    testBlock(expectedTask, expectedResponseObject);
    XCTAssertEqualObjects(expectedTask, actualTask);
    XCTAssertEqualObjects(expectedResponseObject, actualResponseObject);
}

#pragma mark - -failureBlockWithCompletion: Tests

- (void)testFailureBlockWithCompletionInvokesCompletion {
    __block NSURLSessionTask *actualTask = nil;
    __block NSError *actualError = nil;
    APISessionFailureBlock testCompletion = ^(NSURLSessionTask *task, NSError *error) {
        actualTask = task;
        actualError = error;
    };

    APISessionFailureBlock testBlock = [self.target failureBlockWithCompletion:testCompletion];
    NSURLSessionDataTask *expectedTask = [[NSURLSessionDataTask alloc] init];
    NSError *expectedError = [NSError errorWithDomain:NSCocoaErrorDomain code:1001 userInfo:nil];
    testBlock(expectedTask, expectedError);
    XCTAssertEqualObjects(expectedTask, actualTask);
    XCTAssertEqualObjects(expectedError, actualError);
}

- (void)testFailureBlockWithCompletionTransformsNSURLErrorDomainNSURLErrorTimedOutToTRErrorDomainNSURLErrorCannotConnectToHost {
    NSError *testError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil];
    __block NSError *expected;
    APISessionFailureBlock testCompletion = ^(NSURLSessionTask *task, NSError *error) {
        expected = error;
    };
    APISessionFailureBlock testBlock = [self.target failureBlockWithCompletion:testCompletion];
    testBlock(nil, testError);
    XCTAssertEqualObjects(expected.domain, TRErrorDomain);
    XCTAssertEqual(expected.code, NSURLErrorCannotConnectToHost);
}

- (void)testFailureBlockWithCompletionTransformsAFNetworkingBadServerResponseToTRErrorDomainUserAuthRequired {
    NSHTTPURLResponse *testResponse = [[NSHTTPURLResponse alloc] initWithURL:nil statusCode:401 HTTPVersion:@"1.1" headerFields:nil];
    NSDictionary *userInfo = @{ AFNetworkingOperationFailingURLResponseErrorKey : testResponse };
    NSError *testError = [NSError errorWithDomain:AFURLResponseSerializationErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
    __block NSError *expected;
    APISessionFailureBlock testCompletion = ^(NSURLSessionTask *task, NSError *error) {
        expected = error;
    };
    APISessionFailureBlock testBlock = [self.target failureBlockWithCompletion:testCompletion];
    testBlock(nil, testError);
    XCTAssertEqualObjects(expected.domain, TRErrorDomain);
    XCTAssertEqual(expected.code, NSURLErrorUserAuthenticationRequired);
}

- (void)testFailureBlockWithCompletionTransformsAFNetworking500ToTRErrorDomainBadServerResponse {
    NSHTTPURLResponse *testResponse = [[NSHTTPURLResponse alloc] initWithURL:nil statusCode:500 HTTPVersion:@"1.1" headerFields:nil];
    NSDictionary *userInfo = @{ AFNetworkingOperationFailingURLResponseErrorKey : testResponse };
    NSError *testError = [NSError errorWithDomain:AFURLResponseSerializationErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
    __block NSError *expected;
    APISessionFailureBlock testCompletion = ^(NSURLSessionTask *task, NSError *error) {
        expected = error;
    };
    APISessionFailureBlock testBlock = [self.target failureBlockWithCompletion:testCompletion];
    testBlock(nil, testError);
    XCTAssertEqualObjects(expected.domain, TRErrorDomain);
    XCTAssertEqual(expected.code, NSURLErrorBadServerResponse);
}

#pragma mark - -termsAndConditionsURL Tests

- (void)testTermsOfServiceURL {
    NSURL *url = [self.target termsOfServiceURL];
    NSString *expected = @"/terms-of-service";
    NSString *actual = [url path];
    XCTAssertEqualObjects(expected, actual);
}

#pragma mark - -privacyPolicyURL Tests

- (void)testPrivacyPolicyURL {
    NSURL *url = [self.target privacyPolicyURL];
    NSString *expected = @"/privacy-policy";
    NSString *actual = [url path];
    XCTAssertEqualObjects(expected, actual);
}

#pragma mark - -loginWithParameters:success:failure: Tests

- (void)testLoginWithParametersSuccessFailureSendsPOST {
//    id mockTarget = OCMPartialMock(self.target);
    id mockTarget = self.mockTarget;
    APISessionSuccessBlock testSuccess = ^(NSURLSessionTask *task, id responseObject) {};
    APISessionFailureBlock testFailure = ^(NSURLSessionTask *task, NSError *error) {};
    OCMStub([mockTarget successBlockWithCompletion:nil]).andReturn(testSuccess);
    OCMStub([mockTarget failureBlockWithCompletion:nil]).andReturn(testFailure);
    OCMExpect([mockTarget POST:@"login/" parameters:nil success:testSuccess failure:testFailure]);
    [mockTarget loginWithParameters:nil success:nil failure:nil];
    OCMVerifyAll(mockTarget);
//    [mockTarget stopMocking];
}

#pragma mark - -carrierRegisterWithParameters:success:failure: Tests

- (void)testCarrierRegisterWithParametersSuccessFailureSendsPOST {
//    id mockTarget = OCMPartialMock(self.target);
    id mockTarget = self.mockTarget;
    APISessionSuccessBlock testSuccess = ^(NSURLSessionTask *task, id responseObject) {};
    APISessionFailureBlock testFailure = ^(NSURLSessionTask *task, NSError *error) {};
    OCMStub([mockTarget successBlockWithCompletion:nil]).andReturn(testSuccess);
    OCMStub([mockTarget failureBlockWithCompletion:nil]).andReturn(testFailure);
    OCMExpect([mockTarget POST:@"carriers/register/" parameters:nil success:testSuccess failure:testFailure]);
    [mockTarget carriersRegisterWithParameters:nil success:nil failure:nil];
    OCMVerifyAll(mockTarget);
//    [mockTarget stopMocking];
}

#pragma mark - -carriersStatusWithParameters:success:failure: Tests

- (void)testCarrirersStatusWithParametersSuccessFailureSendsGET {
//    id mockTarget = OCMPartialMock(self.target);
    id mockTarget = self.mockTarget;
    id mockRequestSerializer = OCMClassMock([AFJSONRequestSerializer class]);
    OCMStub([mockTarget authorizedRequestSerializer]).andReturn(mockRequestSerializer);
    APISessionSuccessBlock testSuccess = ^(NSURLSessionTask *task, id responseObject) {};
    APISessionFailureBlock testFailure = ^(NSURLSessionTask *task, NSError *error) {};
    OCMStub([mockTarget successBlockWithCompletion:nil]).andReturn(testSuccess);
    OCMStub([mockTarget failureBlockWithCompletion:nil]).andReturn(testFailure);

    OCMExpect([mockTarget GET:@"carriers/status/" parameters:nil success:testSuccess failure:testFailure]);
    [mockTarget carriersStatusWithParameters:nil success:nil failure:nil];
    OCMVerifyAll(mockTarget);
//    [mockTarget stopMocking];
}

#pragma mark - -patchCarriersSingleWithParameters:success:failure: Tests

- (void)testPatchCarriersSingleWithParametersSuccessFailureSendsPATCH {
//    id mockTarget = OCMPartialMock(self.target);
    id mockTarget = self.mockTarget;
    id mockRequestSerializer = OCMClassMock([AFJSONRequestSerializer class]);
    OCMStub([mockTarget authorizedRequestSerializer]).andReturn(mockRequestSerializer);
    APISessionSuccessBlock testSuccess = ^(NSURLSessionTask *task, id responseObject) {};
    APISessionFailureBlock testFailure = ^(NSURLSessionTask *task, NSError *error) {};
    OCMStub([mockTarget successBlockWithCompletion:nil]).andReturn(testSuccess);
    OCMStub([mockTarget failureBlockWithCompletion:nil]).andReturn(testFailure);

    OCMExpect([mockTarget PATCH:@"carriers/single/" parameters:nil success:testSuccess failure:testFailure]);
    [mockTarget patchCarriersSingleWithParameters:nil success:nil failure:nil];
    OCMVerifyAll(mockTarget);
//    [mockTarget stopMocking];
}

#pragma mark - -carriersSelfDriverNestedParameters:success:failure: Tests

- (void)testUsersSelfParametersSuccessFailureSendsPATCH {
//    id mockTarget = OCMPartialMock(self.target);
    id mockTarget = self.mockTarget;
    id mockRequestSerializer = OCMClassMock([AFJSONRequestSerializer class]);
    OCMStub([mockTarget authorizedRequestSerializer]).andReturn(mockRequestSerializer);
    APISessionSuccessBlock testSuccess = ^(NSURLSessionTask *task, id responseObject) {};
    APISessionFailureBlock testFailure = ^(NSURLSessionTask *task, NSError *error) {};
    OCMStub([mockTarget successBlockWithCompletion:nil]).andReturn(testSuccess);
    OCMStub([mockTarget failureBlockWithCompletion:nil]).andReturn(testFailure);
    
    OCMExpect([mockTarget GET:@"carriers/self/drivers/?nested=true" parameters:nil success:testSuccess failure:testFailure]);
    [mockTarget usersSelfParameters:nil success:nil failure:nil];
    OCMVerifyAll(mockTarget);
//    [mockTarget stopMocking];
}

#pragma mark - -patchCarriersSelfDriverNestedParameters:success:failure: Tests

- (void)testPatchUsersSelfParametersSuccessFailureSendsPATCH {
//    id mockTarget = OCMPartialMock(self.target);
    id mockTarget = self.mockTarget;
    id mockRequestSerializer = OCMClassMock([AFJSONRequestSerializer class]);
    OCMStub([mockTarget authorizedRequestSerializer]).andReturn(mockRequestSerializer);
    APISessionSuccessBlock testSuccess = ^(NSURLSessionTask *task, id responseObject) {};
    APISessionFailureBlock testFailure = ^(NSURLSessionTask *task, NSError *error) {};
    OCMStub([mockTarget successBlockWithCompletion:nil]).andReturn(testSuccess);
    OCMStub([mockTarget failureBlockWithCompletion:nil]).andReturn(testFailure);
    
    OCMExpect([mockTarget PATCH:@"carriers/self/drivers/?nested=true" parameters:nil success:testSuccess failure:testFailure]);
    [mockTarget patchUsersSelfParameters:nil success:nil failure:nil];
    OCMVerifyAll(mockTarget);
//    [mockTarget stopMocking];
}

#pragma mark - -carriersShipmentsTempWithParameters:success:failure: Tests

- (void)testCarriersShipmentsTempWithParametersSuccessFailureSendsGET {
//    id mockTarget = OCMPartialMock(self.target);
    id mockTarget = self.mockTarget;
    id mockRequestSerializer = OCMClassMock([AFJSONRequestSerializer class]);
    OCMStub([mockTarget authorizedRequestSerializer]).andReturn(mockRequestSerializer);
    APISessionSuccessBlock testSuccess = ^(NSURLSessionTask *task, id responseObject) {};
    APISessionFailureBlock testFailure = ^(NSURLSessionTask *task, NSError *error) {};
    OCMStub([mockTarget successBlockWithCompletion:nil]).andReturn(testSuccess);
    OCMStub([mockTarget failureBlockWithCompletion:nil]).andReturn(testFailure);
    
    OCMExpect([mockTarget GET:@"carriers/shipments/temp/" parameters:nil success:testSuccess failure:testFailure]);
    [mockTarget carriersShipmentsTempWithParameters:nil success:nil failure:nil];
    OCMVerifyAll(mockTarget);
//    [mockTarget stopMocking];
}

#pragma mark - -patchShipment:parameters:success:failure: Tests

- (void)testPatchShipmentParametersSuccessFailureSendsPATCH {
//    id mockTarget = OCMPartialMock(self.target);
    id mockTarget = self.mockTarget;
    id mockRequestSerializer = OCMClassMock([AFJSONRequestSerializer class]);
    OCMStub([mockTarget authorizedRequestSerializer]).andReturn(mockRequestSerializer);
    APISessionSuccessBlock testSuccess = ^(NSURLSessionTask *task, id responseObject) {};
    APISessionFailureBlock testFailure = ^(NSURLSessionTask *task, NSError *error) {};
    OCMStub([mockTarget successBlockWithCompletion:nil]).andReturn(testSuccess);
    OCMStub([mockTarget failureBlockWithCompletion:nil]).andReturn(testFailure);
    
    id mockShipment = OCMClassMock([Shipment class]);
    NSString *serverId = [NSString stringWithFormat:@"%ld", (long)self.randomInteger];
    OCMStub([mockShipment traansmissionId]).andReturn(serverId);
    NSString *urlString = [NSString stringWithFormat:@"carriers/shipments/%@/", serverId];
    OCMExpect([mockTarget PATCH:urlString parameters:nil success:testSuccess failure:testFailure]);
    [mockTarget patchShipment:mockShipment parameters:nil success:nil failure:nil];
    OCMVerifyAll(mockTarget);
//    [mockTarget stopMocking];
}

#pragma mark - -postAcceptTOSWithParameters:success:failure: Tests

- (void)testPostAcceptTOSWithParametersSuccessFailureSendsPOST {
//    id mockTarget = OCMPartialMock(self.target);
    id mockTarget = self.mockTarget;
    id mockRequestSerializer = OCMClassMock([AFJSONRequestSerializer class]);
    OCMStub([mockTarget authorizedRequestSerializer]).andReturn(mockRequestSerializer);
    APISessionSuccessBlock testSuccess = ^(NSURLSessionTask *task, id responseObject) {};
    APISessionFailureBlock testFailure = ^(NSURLSessionTask *task, NSError *error) {};
    OCMStub([mockTarget successBlockWithCompletion:nil]).andReturn(testSuccess);
    OCMStub([mockTarget failureBlockWithCompletion:nil]).andReturn(testFailure);
    
    OCMExpect([mockTarget POST:@"tos/" parameters:nil success:testSuccess failure:testFailure]);
    [mockTarget postAcceptTOSWithParameters:nil success:nil failure:nil];
    OCMVerifyAll(mockTarget);
//    [mockTarget stopMocking];
}

#pragma mark - -postFile:parameters:success:failure: Tests

- (void)PENDING_testPostFileParametersSuccessFailure {
    
}

#pragma mark - -postGeoLocation:parameters:success:failure: Tests

- (void)testPostGeoLocationParametersSuccessFailureSendsPOST {
//    id mockTarget = OCMPartialMock(self.target);
    id mockTarget = self.mockTarget;
    id mockRequestSerializer = OCMClassMock([AFJSONRequestSerializer class]);
    OCMStub([mockTarget authorizedRequestSerializer]).andReturn(mockRequestSerializer);
    
    CLLocation *location = [[CLLocation alloc] init];
    APISessionSuccessBlock testSuccess = ^(NSURLSessionTask *task, id responseObject) {};
    APISessionFailureBlock testFailure = ^(NSURLSessionTask *task, NSError *error) {};
    OCMStub([mockTarget successBlockWithCompletion:nil]).andReturn(testSuccess);
    OCMStub([mockTarget failureBlockWithCompletion:nil]).andReturn(testFailure);
    OCMExpect([mockTarget POST:@"geolocations/" parameters:[OCMArg isKindOfClass:[NSDictionary class]] success:testSuccess failure:testFailure]);
    [mockTarget postGeoLocation:location parameters:nil success:nil failure:nil];
    OCMVerifyAll(mockTarget);
//    [mockTarget stopMocking];
}

#pragma mark - -shipmentWithId:parameters:success:failure: Tests

- (void)PENDING_testShipmentWithIdParametersSuccessFailure {
}

#pragma mark - -claimShipmentWithId:parameters:success:failure: Tests

- (void)PENDING_testClaimShipmentWithIdParametersSuccessFailure {
}

@end
