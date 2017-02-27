//
//  AnalyticsInitializer.m
//  Impaqd
//
//  Created by Traansmission on 4/23/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "AnalyticsInitializer.h"
#import <apptentive-ios/ATConnect.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Mixpanel/Mixpanel.h>
#import "constants.h"

@interface AnalyticsInitializer ()

@property (copy) InitializerCallback callback;
@property (nonatomic, copy) NSURL *baseURL;

@end

@implementation AnalyticsInitializer

- (instancetype)initWithCallback:(InitializerCallback)callback {
    self = [super init];
    if (self) {
        self.callback = callback;
    }
    return self;
}

- (void)didFinishLaunching {
    [ATConnect sharedConnection].apiKey = @"fbe1c28e7e6bdf8642686ccd4c16f96377a61ed56362a72954103b85ed4c4c27";
#if !(TARGET_IPHONE_SIMULATOR)
    [Fabric with:@[CrashlyticsKit]];
    [Mixpanel sharedInstanceWithToken:kMixpanelToken];
#endif

    //ANALYTICS START
    //We want to associate the url (dev, demo or production) with all mixpanel calls
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel registerSuperProperties:@{ @"server_url" : kBaseURL }];
    //ANALYTICS END
    
    if (self.callback) {
        self.callback(nil);
    }
}

- (void)willEnterForeground {
}

- (void)didEnterBackground {
}

#pragma mark - Private Instance Methods

@end
