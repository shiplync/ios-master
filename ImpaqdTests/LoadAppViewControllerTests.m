//
//  LoadAppViewControllerTests.m
//  Impaqd
//
//  Created by Traansmission on 4/24/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "LoadAppViewController.h"
#import "SVProgressHUD.h"

@interface LoadAppViewControllerTests : TRTestCase

@property (nonatomic) LoadAppViewController *target;

@end

@implementation LoadAppViewControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.target = [[LoadAppViewController alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.target = nil;
    [super tearDown];
}

- (void)testInitialization {
    XCTAssertTrue([self.target isKindOfClass:[LoadAppViewController class]]);
}

#pragma mark - -viewDidLoad Tests

- (void)testViewDidLoadAddsLaunchScreenNibAsFrontmostSubview {
    id mockNib = OCMClassMock([UINib class]);
    OCMStub([mockNib nibWithNibName:@"LaunchScreen" bundle:[OCMArg isNil]]).andReturn(mockNib);
    UIView *testView = [[UIView alloc] init];
    NSArray *nibObjects = @[ testView ];
    OCMStub([mockNib instantiateWithOwner:[OCMArg isNil] options:[OCMArg isNil]]).andReturn(nibObjects);
    XCTAssertNotNil(self.target.view);    // invoke -viewDidLoad
    XCTAssertEqualObjects([self.target.view.subviews lastObject], testView);
    
    [mockNib stopMocking];
}

#pragma mark - -viewDidAppear: Tests

- (void)testViewDidAppearShowSVProgressHUD {
    id mockProgessHUD = OCMClassMock([SVProgressHUD class]);
    [self.target viewDidAppear:NO];
    OCMVerify(ClassMethod([mockProgessHUD show]));
    [mockProgessHUD stopMocking];
}

#pragma mark - -viewWillDisappear: Tests

- (void)testViewWillDisappearDismissesSVProgressHUD {
    id mockProgessHUD = OCMClassMock([SVProgressHUD class]);
    [self.target viewWillDisappear:NO];
    OCMVerify(ClassMethod([mockProgessHUD dismiss]));
    [mockProgessHUD stopMocking];
}

#pragma mark - -presentViewController:animated:completion: Tests

- (void)testPresentViewControllerAnimatedCompletionDismissesSVProgressHUD {
    id mockProgessHUD = OCMClassMock([SVProgressHUD class]);
    UIViewController *testController = [[UIViewController alloc] init];
    [self.target presentViewController:testController animated:NO completion:nil];
    OCMVerify(ClassMethod([mockProgessHUD dismiss]));
    [mockProgessHUD stopMocking];
}

#pragma mark - -dismissViewControllerAnimated:completion: Tests

- (void)testDismissViewControllerAnimatedCompletionShowsSVProgressHUD {
    id mockProgessHUD = OCMClassMock([SVProgressHUD class]);
    [self.target dismissViewControllerAnimated:NO completion:nil];
    OCMVerify(ClassMethod([mockProgessHUD show]));
    [mockProgessHUD stopMocking];
}

@end
