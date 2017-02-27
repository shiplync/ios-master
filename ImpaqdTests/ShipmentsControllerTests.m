//
//  ShipmentsControllerTests.m
//  Impaqd
//
//  Created by Traansmission on 4/28/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "ShipmentsController.h"
#import "APISessionManager.h"
#import "Shipment.h"

@interface ShipmentsController (TestExtensions)
@property (nonatomic, readwrite) NSArray *shipments;
@property (nonatomic, readwrite) NSArray *activeShipments;
@property (nonatomic, readwrite) NSArray *completedShipments;
@end

@interface ShipmentsControllerTests : TRTestCase

@property (nonatomic) ShipmentsController *target;

@end

@implementation ShipmentsControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.target = [[ShipmentsController alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.target = nil;
    [super tearDown];
}

- (void)testInitialization {
    XCTAssertTrue([self.target isKindOfClass:[ShipmentsController class]]);
}

#pragma mark - -performFetchWithCallback: Tests

- (void)testPerformFetchWithCallbackInvokesAPISessionManager {
    id mockManager = OCMClassMock([APISessionManager class]);
    OCMStub([mockManager sharedManager]).andReturn(mockManager);
    [self.target performFetchWithCallback:nil];
    OCMVerify([mockManager carriersShipmentsTempWithParameters:nil success:[OCMArg any] failure:[OCMArg any]]);
    [mockManager stopMocking];
}

#pragma mark - -numberOfSections Tests

- (void)testNumberOfSectionsIsOne {
    XCTAssertEqual(1, [self.target numberOfSections]);
}

#pragma mark - -numberOfRowsInSection: Tests

- (void)testNumberOfRowsInSectionReturnSizeOfShipmentsArray {
    NSInteger expected = arc4random_uniform(BUFSIZ);
    NSMutableArray *testArray = [NSMutableArray array];
    for (NSInteger i = 0; i < expected; i++) {
        [testArray addObject:[[Shipment alloc] init]];
    }
    self.target.shipments = testArray;
    
    NSInteger actual = [self.target numberOfRowsInSection:0];
    XCTAssertEqual(expected, actual);
}

#pragma mark - -shipmentAtIndexPath: Tests

- (void)testShipmentAtIndexPathReturnsShipmentAtIndexPathRow {
    NSInteger size = arc4random_uniform(BUFSIZ);
    NSMutableArray *testArray = [NSMutableArray array];
    for (NSInteger i = 0; i < size; i++) {
        [testArray addObject:[[Shipment alloc] init]];
    }
    self.target.shipments = testArray;

    NSInteger row = arc4random_uniform((u_int32_t)size);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    Shipment *expected = testArray[row];
    Shipment *actual = [self.target shipmentAtIndexPath:indexPath];
    XCTAssertEqualObjects(expected, actual);
}

#pragma mark - -setActiveShipments

- (void)testSetActiveShipmentsSetsShipmentsToActiveShipments {
    self.target.activeShipments = [NSArray array];
    XCTAssertNotEqualObjects(self.target.shipments, self.target.activeShipments);
    [self.target setActiveShipments];
    XCTAssertEqualObjects(self.target.shipments, self.target.activeShipments);
}

#pragma mark - -setCompleteShipments

- (void)testSetCompletedShipmentsSetsShipmentsToCompleteShipments {
    self.target.completedShipments = [NSArray array];
    XCTAssertNotEqualObjects(self.target.shipments, self.target.completedShipments);
    [self.target setCompletedShipments];
    XCTAssertEqualObjects(self.target.shipments, self.target.completedShipments);
}

@end
