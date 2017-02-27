//
//  PushNotificationTests.m
//  Impaqd
//
//  Created by Traansmission on 6/12/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <KIF/KIF.h>
#import <KIF/UIAutomationHelper.h>
#import "ACSimulatorRemoteNotificationsService.h"
#import "OHHTTPStubsHelper.h"

@interface PushNotificationTests : KIFTestCase

@end

@implementation PushNotificationTests

- (void)beforeAll {
    [[OHHTTPStubsHelper sharedInstance] setUpLoginSuccessStubs];
    [[OHHTTPStubsHelper sharedInstance] setUpOpenShipmentsStubs];
}

- (void)beforeEach {
    [tester waitForViewWithAccessibilityLabel:@"WelcomeView"];
    [tester tapViewWithAccessibilityLabel:@"LoginButton"];
    
    [tester enterText:@"test.carrier@example.com" intoViewWithAccessibilityLabel:@"EmailTextField"];
    [tester enterText:@"password" intoViewWithAccessibilityLabel:@"PasswordTextField"];
    [tester tapViewWithAccessibilityLabel:@"Login"];
}

- (void)afterEach {
}

- (void)afterAll {
    [[OHHTTPStubsHelper sharedInstance] tearDownStubs];
}

- (void)testDisplayShipmentDetailsFromPushNotification {
    [tester waitForViewWithAccessibilityLabel:@"OpenShipmentsViewController"];
    
    NSURL *fixtureURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"single-load-rec-push" withExtension:@"json"];
    NSData *fixtureData = [NSData dataWithContentsOfURL:fixtureURL];
    NSError *error;
    NSDictionary *fixture = [NSJSONSerialization JSONObjectWithData:fixtureData options:0 error:&error];
    [[ACSimulatorRemoteNotificationsService sharedService] send:fixture];
    
    [tester waitForTappableViewWithAccessibilityLabel:@"Show"];
    [tester tapViewWithAccessibilityLabel:@"Show"];
    
    [tester waitForViewWithAccessibilityLabel:@"ShipmentDetailsTableViewController"];
}

- (void)testDisplayActiveShipmentsFromPushNotification {
    [tester waitForViewWithAccessibilityLabel:@"OpenShipmentsViewController"];
    
    NSURL *fixtureURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"load-request-approved-push" withExtension:@"json"];
    NSData *fixtureData = [NSData dataWithContentsOfURL:fixtureURL];
    NSError *error;
    NSDictionary *fixture = [NSJSONSerialization JSONObjectWithData:fixtureData options:0 error:&error];
    [[ACSimulatorRemoteNotificationsService sharedService] send:fixture];
    
    [tester waitForTappableViewWithAccessibilityLabel:@"Show"];
    [tester tapViewWithAccessibilityLabel:@"Show"];
    
    [tester waitForViewWithAccessibilityLabel:@"ShipmentsTableViewController"];
}

@end
