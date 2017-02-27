//
//  OHHTTPStubsHelper.h
//  Impaqd
//
//  Created by Traansmission on 5/5/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <OHHTTPStubs/OHHTTPStubs.h>

@interface OHHTTPStubsHelper : NSObject

+ (instancetype)sharedInstance;

- (void)setUpStubs;
- (void)tearDownStubs;

- (void)setUpLoginSuccessStubs;
- (void)setUpOpenShipmentsStubs;

@end
