//
//  LoginTests.m
//  Impaqd
//
//  Created by Traansmission on 5/5/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <KIF/KIF.h>
#import "OHHTTPStubsHelper.h"

#import "AccountController.h"

@interface LoginTests : KIFTestCase

@end

@implementation LoginTests

- (void)beforeAll {
    [[OHHTTPStubsHelper sharedInstance] setUpLoginSuccessStubs];
}

- (void)beforeEach {
    
}

- (void)afterEach {
    [[AccountController sharedInstance] logoutWithCompletion:nil];
}

- (void)afterAll {
    [[OHHTTPStubsHelper sharedInstance] tearDownStubs];
}

- (void)testSuccessfulLogin {
    [tester waitForViewWithAccessibilityLabel:@"WelcomeView"];
    [tester tapViewWithAccessibilityLabel:@"LoginButton"];
    
    [tester enterText:@"test.carrier@example.com" intoViewWithAccessibilityLabel:@"EmailTextField"];
    [tester enterText:@"password" intoViewWithAccessibilityLabel:@"PasswordTextField"];
    [tester tapViewWithAccessibilityLabel:@"Login"];
    [tester waitForViewWithAccessibilityLabel:@"PermissionsViewController"];
}
@end
