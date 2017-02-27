//
//  TRTestCase.m
//  Impaqd
//
//  Created by Traansmission on 4/3/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRTestCase.h"

@implementation TRTestCase

- (NSInteger)randomInteger {
    return (NSInteger)arc4random_uniform(INT32_MAX);
}

- (NSString *)randomSentence {
    return [MBFakerLorem sentence];
}

- (CLLocation *)randomLocation {
    CLLocationDegrees latitude = (CLLocationDegrees)(arc4random_uniform(180)) - 90.0f;
    CLLocationDegrees longitude = (CLLocationDegrees)(arc4random_uniform(360)) - 180.0f;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    return location;
}

@end
