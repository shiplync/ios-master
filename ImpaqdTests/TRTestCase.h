//
//  TRTestCase.h
//  Impaqd
//
//  Created by Traansmission on 4/3/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <MBFaker/MBFaker.h>
#import <MapKit/MapKit.h>

static NSString const *TRTestErrorDomain = @"com.traansmission.test.errors";

@interface TRTestCase : XCTestCase

@property (nonatomic, readonly) NSInteger randomInteger;
@property (nonatomic, readonly) NSString *randomSentence;
@property (nonatomic, readonly) CLLocation *randomLocation;

@end
