//
//  UIAlertControllerTraansmissionKitTests.m
//  Impaqd
//
//  Created by Traansmission on 4/24/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

//
//  TRAlertControllerTests.m
//  Impaqd
//
//  Created by Traansmission on 4/21/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"
#import "UIAlertController+TraansmissionKit.h"
#import "NSError+TraansmissionKit.h"

@interface TestRecoveryAttempter : NSObject
@property (copy) dispatch_block_t block;
@end

@implementation TestRecoveryAttempter
- (BOOL)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex {
    if (self.block) {
        self.block();
    }
    return YES;
}
@end


@interface TRAlertControllerTests : TRTestCase

@property (nonatomic) UIAlertController *target;

@end

@implementation TRAlertControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - +alertControllerWithError: Tests

- (void)testAlertControllerWithErrorSetsTitleFromErrorLocalizedAlertTitle {
    NSString *expected = self.randomSentence;
    
    id mockError = OCMClassMock([NSError class]);
    OCMStub([mockError localizedAlertTitle]).andReturn(expected);
    UIAlertController *target = [UIAlertController alertControllerWithError:mockError];
    
    XCTAssertEqualObjects(expected, target.title);
}

- (void)testAlertControllerWithErrorSetsMessageFromErrorLocalizedAlertMessage {
    NSString *expected = self.randomSentence;
    
    id mockError = OCMClassMock([NSError class]);
    OCMStub([mockError localizedAlertMessage]).andReturn(expected);
    UIAlertController *target = [UIAlertController alertControllerWithError:mockError];
    
    XCTAssertEqualObjects(expected, target.message);
}

- (void)testAlertControllerWithErrorHasOneActionIfErrorHasNoRecoveryOptions {
    id mockError = OCMClassMock([NSError class]);
    OCMStub([mockError localizedRecoveryOptions]).andReturn(nil);
    UIAlertController *target = [UIAlertController alertControllerWithError:mockError];
    
    NSArray *actions = target.actions;
    XCTAssertEqual(1, [actions count]);
    
    UIAlertAction *action = [actions firstObject];
    XCTAssertEqualObjects(@"OK", action.title);
}

- (void)testAlertControllerWithErrorHasOneActionIfErrorRecoveryOptionsEmpty {
    id mockError = OCMClassMock([NSError class]);
    OCMStub([mockError localizedRecoveryOptions]).andReturn(@[]);
    UIAlertController *target = [UIAlertController alertControllerWithError:mockError];
    
    NSArray *actions = target.actions;
    XCTAssertEqual(1, [actions count]);
    
    UIAlertAction *action = [actions firstObject];
    XCTAssertEqualObjects(@"OK", action.title);
}

- (void)testAlertControllerWithErrorActionTitlesMatchErrorRecoverOptions {
    NSArray *recoveryOptions = [self.randomSentence componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    id mockError = OCMClassMock([NSError class]);
    OCMStub([mockError localizedRecoveryOptions]).andReturn(recoveryOptions);
    UIAlertController *target = [UIAlertController alertControllerWithError:mockError];
    
    NSArray *actions = target.actions;
    XCTAssertEqual([recoveryOptions count], [actions count]);
    
    for (NSInteger i = 0; i < [recoveryOptions count]; i++) {
        NSString *expected = recoveryOptions[i];
        NSString *actual = [actions[i] title];
        XCTAssertEqualObjects(expected, actual);
    }
}

@end
