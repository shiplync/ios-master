//
//  OpenShipmentsControllerTests.m
//  Impaqd
//
//  Created by Traansmission on 6/4/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "OpenShipmentsController.h"
#import "APISessionManager.h"
#import "Shipment.h"

@interface OpenShipmentsController (TestExtension)

@property (nonatomic, readwrite) NSMutableArray *pagedShipments;
- (NSArray *)allShipments;

@end


@interface OpenShipmentsControllerTests : TRTestCase

@property (nonatomic) OpenShipmentsController *target;

@end


@implementation OpenShipmentsControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.target = [[OpenShipmentsController alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.target = nil;
    [super tearDown];
}

- (NSInteger)setUpPagedShipments {
    self.target.pagedShipments = [NSMutableArray array];
    NSInteger count = 0;
    NSInteger numberOfPages = arc4random_uniform(10);
    for (NSInteger i = 0; i < numberOfPages; i++) {
        NSInteger pageSize = arc4random_uniform(BUFSIZ);
        NSMutableArray *testArray = [NSMutableArray arrayWithCapacity:pageSize];
        for (NSInteger i = 0; i < pageSize; i++) {
            [testArray addObject:[[Shipment alloc] init]];
        }
        [self.target.pagedShipments addObject:testArray];
        count += pageSize;
    }
    return count;
}

- (void)testInitialization {
    XCTAssertTrue([self.target isKindOfClass:[OpenShipmentsController class]]);
}


#pragma mark - -performFetchWithCallback: Tests

- (void)testPerformFetchWithCallbackInvokesAPISessionManager {
    id mockManager = OCMClassMock([APISessionManager class]);
    OCMStub([mockManager sharedManager]).andReturn(mockManager);
    [self.target performFetchWithCallback:nil];
    OCMVerify([mockManager openShipmentsWithParameters:[OCMArg isKindOfClass:[NSDictionary class]] success:[OCMArg any] failure:[OCMArg any]]);
    [mockManager stopMocking];
}


#pragma mark - -numberOfSections Tests

- (void)testNumberOfSectionsIsOne {
    XCTAssertEqual(1, [self.target numberOfSections]);
}


#pragma mark - -numberOfRowsInSection: Tests

- (void)testNumberOfRowsInSectionReturnSizeOfAllShipmentsArray {
    NSInteger expected = [self setUpPagedShipments];
    NSInteger actual = [self.target numberOfRowsInSection:0];
    XCTAssertEqual(expected, actual);
}


#pragma mark - -shipmentAtIndexPath: Tests

- (void)testShipmentAtIndexPathReturnsShipmentAtIndexPathRow {
    NSInteger size = [self setUpPagedShipments];
    NSInteger row = arc4random_uniform((u_int32_t)size);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    Shipment *expected = [[self.target allShipments] objectAtIndex:row];
    Shipment *actual = [self.target shipmentAtIndexPath:indexPath];
    XCTAssertEqualObjects(expected, actual);
}


@end
