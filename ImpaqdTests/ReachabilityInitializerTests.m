//
//  ReachabilityInitializerTests.m
//  Impaqd
//
//  Created by Traansmission on 4/24/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "ReachabilityInitializer.h"
#import "APISessionManager.h"

@interface ReachabilityInitializerTests : TRTestCase

@property (nonatomic) ReachabilityInitializer *target;

@end

@implementation ReachabilityInitializerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.target = [[ReachabilityInitializer alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.target = nil;
    [super tearDown];
}
                   
- (void)testInitialization {
    XCTAssertTrue([self.target isKindOfClass:[ReachabilityInitializer class]]);
}

#pragma mark - -didFinishLaunching Tests

- (void)testDidFinishLaunchingSetsAPISessionManagerReachabilityManagerStatusChangedBlock {
    id mockSessionManager = OCMClassMock([APISessionManager class]);
    OCMStub([mockSessionManager sharedManager]).andReturn(mockSessionManager);
    id mockReachabilityManager = OCMClassMock([AFNetworkReachabilityManager class]);
    OCMStub([mockSessionManager reachabilityManager]).andReturn(mockReachabilityManager);
    
    [self.target didFinishLaunching];
    OCMVerify([mockReachabilityManager setReachabilityStatusChangeBlock:[OCMArg any]]);
    
    [mockSessionManager stopMocking];
}

- (void)testDidFinishLaunchingStartsReachabilityManagerMonitoring {
    id mockSessionManager = OCMClassMock([APISessionManager class]);
    OCMStub([mockSessionManager sharedManager]).andReturn(mockSessionManager);
    id mockReachabilityManager = OCMClassMock([AFNetworkReachabilityManager class]);
    OCMStub([mockSessionManager reachabilityManager]).andReturn(mockReachabilityManager);
    
    [self.target didFinishLaunching];
    OCMVerify([mockReachabilityManager startMonitoring]);
    
    [mockSessionManager stopMocking];
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
