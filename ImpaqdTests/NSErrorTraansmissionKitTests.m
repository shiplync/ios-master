//
//  NSErrorTraansmissionKitTests.m
//  Impaqd
//
//  Created by Traansmission on 4/9/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "NSError+TraansmissionKit.h"

@interface NSErrorTraansmissionKitTests : TRTestCase

@end

@implementation NSErrorTraansmissionKitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - +errorWithCode:userInfo: Tests

- (void)testErrorWithCodeUserInfoSetErrorDomain {
    NSError *target = [NSError errorWithCode:self.randomInteger userInfo:nil];
    XCTAssertEqualObjects(target.domain, TRErrorDomain);
}

- (void)testErrorWithCodeUserInfoSetErrorCode {
    NSInteger expected = self.randomInteger;
    NSError *target = [NSError errorWithCode:expected userInfo:nil];
    XCTAssertEqual(expected, target.code);
}

- (void)testErrorWithCodeUserInfoSetUserInfo {
    NSDictionary *expected = [NSDictionary dictionary];
    NSError *target = [NSError errorWithCode:self.randomInteger userInfo:expected];
    XCTAssertEqualObjects(expected, target.userInfo);
}

#pragma mark - +errorWithCode:description: Tests

- (void)testErrorWithCodeDescriptionSetsUserInfoDescription {
    NSString *expected = self.randomSentence;
    NSError *target = [NSError errorWithCode:self.randomInteger description:expected];
    XCTAssertEqualObjects(expected, target.userInfo[NSLocalizedDescriptionKey]);
}

#pragma mark - +errorWithCode:description:reason: Tests

- (void)testErrorWithCodeDescriptionReasonSetsUserInfoReason {
    NSString *expected = self.randomSentence;
    NSError *target = [NSError errorWithCode:self.randomInteger description:self.randomSentence reason:expected];
    XCTAssertEqualObjects(expected, target.userInfo[NSLocalizedFailureReasonErrorKey]);
}

#pragma mark - +errorWithCode:description:reason:recovery: Tests

- (void)testErrorWithCodeDescriptionReasonRecoverySetsUserInfoRecovery {
    NSString *expected = self.randomSentence;
    NSError *target = [NSError errorWithCode:self.randomInteger description:self.randomSentence reason:self.randomSentence recovery:expected];
    XCTAssertEqualObjects(expected, target.userInfo[NSLocalizedRecoverySuggestionErrorKey]);
}

#pragma mark - +errorWithCode:description:reason:recovery:options: Tests

- (void)testErrorWithCodeDescriptionReasonRecoveryOptionsSetsUserInfoOptions {
    NSArray *expected = [NSArray array];
    NSError *target = [NSError errorWithCode:self.randomInteger description:self.randomSentence reason:self.randomSentence recovery:self.randomSentence options:expected];
    XCTAssertEqualObjects(expected, target.userInfo[NSLocalizedRecoveryOptionsErrorKey]);
}

#pragma mark - +errorWithCode:description:reason:recovery:options:attempter: Tests

- (void)testErrorWithCodeDescriptionReasonRecoveryOptionsAttempterSetsUserInfoOptions {
    NSObject *expected = [[NSObject alloc] init];
    NSError *target = [NSError errorWithCode:self.randomInteger description:self.randomSentence reason:self.randomSentence recovery:self.randomSentence options:@[] attempter:expected];
    XCTAssertEqualObjects(expected, target.userInfo[NSRecoveryAttempterErrorKey]);
}

#pragma mark - -URLCannotConnectToHostWithAttempter: Tests

- (void)PENDING_testURLCannotConnectToHostWithAttempter {
    
}

#pragma mark - -serverError Tests

- (void)testServerError {
    NSError *target = [NSError serverError];
    XCTAssertEqual(target.code, NSURLErrorBadServerResponse);
}

#pragma mark - -localizedAlertTitle Tests

- (void)testLocalizedAlertTitleReturnsLocalizedDescription {
    NSString *expected = self.randomSentence;
    
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : expected };
    NSError *target = [NSError errorWithCode:self.randomInteger userInfo:userInfo];
    
    XCTAssertEqualObjects(expected, target.localizedAlertTitle);
}

#pragma mark - -localizedAlertMessage Tests

- (void)testLocalizedAlertMessageContainsLocalizedFailureReason {
    NSString *expected = self.randomSentence;
    
    NSDictionary *userInfo = @{ NSLocalizedFailureReasonErrorKey : expected };
    NSError *target = [NSError errorWithCode:self.randomInteger userInfo:userInfo];
    
    XCTAssertTrue([target.localizedAlertMessage containsString:expected]);
}

- (void)testLocalizedAlertMessageContainsLocalizedRecoverySuggestionIfNotNIL {
    NSString *expected = self.randomSentence;
    
    NSDictionary *userInfo = @{ NSLocalizedFailureReasonErrorKey : self.randomSentence,
                                NSLocalizedRecoverySuggestionErrorKey : expected };
    NSError *target = [NSError errorWithCode:self.randomInteger userInfo:userInfo];
    
    XCTAssertTrue([target.localizedAlertMessage containsString:expected]);
}

@end
