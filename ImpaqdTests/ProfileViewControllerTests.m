//
//  ProfileViewControllerTests.m
//  Impaqd
//
//  Created by Traansmission on 4/27/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "ProfileViewController.h"

#import "TRWebViewController.h"
#import "APISessionManager.h"

@interface ProfileViewControllerTests : TRTestCase

@property (nonatomic) ProfileViewController *target;

@end

@implementation ProfileViewControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.target = [[ProfileViewController alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.target = nil;
    [super tearDown];
}

#pragma mark - -prepareForSegue:sender: Tests

- (void)testPrepareForSegueSenderSetsURLWithSenderForSegueIdentifierWebViewSegue {
    id mockSegue = OCMClassMock([UIStoryboardSegue class]);
    OCMStub([mockSegue identifier]).andReturn(@"webViewSegue");

    id mockVC = OCMClassMock([TRWebViewController class]);
    OCMStub([mockSegue destinationViewController]).andReturn(mockVC);
    
    NSURL *testURL = [NSURL URLWithString:@"http://example.com/"];
    [self.target prepareForSegue:mockSegue sender:testURL];
    OCMVerify([mockVC setURL:testURL]);
}


#pragma mark - UITableViewDelegate Method Tests

#pragma mark - -tableView:willSelectRowAtIndexPath: Tests

- (void)testTableViewWillSelectRowAtIndexPathReturnsNIL {
    XCTAssertNil([self.target tableView:nil willSelectRowAtIndexPath:nil]);
}

- (void)testTableViewWillSelectRowAtIndexPathPerformsWebViewSegueWithTermsOfServiceURLForIndexPath3_0 {
    id mockTarget = OCMPartialMock(self.target);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:4];
    NSURL *tosURL = [[APISessionManager sharedManager] termsOfServiceURL];
    OCMExpect([mockTarget performSegueWithIdentifier:@"webViewSegue" sender:tosURL]);
    [mockTarget tableView:nil willSelectRowAtIndexPath:indexPath];
    OCMVerifyAll(mockTarget);
    [mockTarget stopMocking];
}

- (void)testTableViewWillSelectRowAtIndexPathPerformsWebViewSegueWithPrivacyPolicyURLForIndexPath3_1 {
    id mockTarget = OCMPartialMock(self.target);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:4];
    NSURL *ppURL = [[APISessionManager sharedManager] privacyPolicyURL];
    OCMExpect([mockTarget performSegueWithIdentifier:@"webViewSegue" sender:ppURL]);
    [mockTarget tableView:nil willSelectRowAtIndexPath:indexPath];
    OCMVerifyAll(mockTarget);
    [mockTarget stopMocking];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
