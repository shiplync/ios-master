//
//  InitializerController.m
//  Impaqd
//
//  Created by Traansmission on 4/24/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "InitializerController.h"
#import "TraansmissionKit.h"
#import "ReachabilityInitializer.h"
#import "AnalyticsInitializer.h"
#import "VersionInitializer.h"
#import "TokenInitializer.h"
#import "AccountInitializer.h"
#import "LocationInitializer.h"
#import <SSKeychain/SSKeychain.h>

@interface InitializerController ()

@property (copy) InitializerCallback callback;
@property (nonatomic, weak) UIWindow *window;

@property (nonatomic) ReachabilityInitializer *reachabilityInitializer;
@property (nonatomic) AnalyticsInitializer *analyticsInitializer;
@property (nonatomic) VersionInitializer *versionInitializer;
@property (nonatomic) TokenInitializer *tokenInitializer;
@property (nonatomic) AccountInitializer *accountInitializer;
@property (nonatomic) LocationInitializer *locationInitializer;

@end

@implementation InitializerController

- (instancetype)initWithCallback:(InitializerCallback)callback {
    NSParameterAssert(callback != nil);
    
    self = [super init];
    if (self) {
        self.callback = callback;
        self.window = [[[UIApplication sharedApplication] delegate] window];
    }
    return self;
}

- (void)didFinishLaunching {
    self.reachabilityInitializer = [[ReachabilityInitializer alloc] initWithCallback:[self reachabilityCallback]];
    self.analyticsInitializer = [[AnalyticsInitializer alloc] initWithCallback:nil];
    self.versionInitializer = [[VersionInitializer alloc] initWithCallback:[self versionCallback]];
    self.tokenInitializer = [[TokenInitializer alloc] initWithCallback:[self tokenCallback]];
    self.accountInitializer = [[AccountInitializer alloc] initWithCallback:[self accountCallback]];
    self.locationInitializer = [[LocationInitializer alloc] initWithCallback:[self locationCallback]];
    
    [self.reachabilityInitializer didFinishLaunching];
}

- (void)willEnterForeground {
    [self.reachabilityInitializer willEnterForeground];
}

- (void)didEnterBackground {
    [self.reachabilityInitializer didEnterBackground];
}

#pragma mark - Private Instance Methods

- (InitializerCallback)reachabilityCallback {
    return ^(NSError *error) {
        if (error) {
            self.callback(error);
            return;
        }
        [self.analyticsInitializer didFinishLaunching];
        [self.versionInitializer didFinishLaunching];
    };
}

- (InitializerCallback)versionCallback {
    return ^(NSError *error) {
        if (error) {
            self.callback(error);
            return;
        }
        [self.tokenInitializer didFinishLaunching];
    };
}

- (InitializerCallback)tokenCallback {
    return ^(NSError *error) {
        if (error) {
            if (([error.domain isEqualToString:kSSKeychainErrorDomain] && error.code == errSecItemNotFound)
                || ([error.domain isEqualToString:TRErrorDomain] && error.code == NSURLErrorUserAuthenticationRequired)) {
                error = [NSError errorWithDomain:TRErrorDomain code:NSURLErrorUserAuthenticationRequired userInfo:nil];
            }
            self.callback(error);
            return;
        }
        [self.accountInitializer didFinishLaunching];
    };
}

- (InitializerCallback)accountCallback {
    return ^(NSError *error) {
        if (error) {
            self.callback(error);
            return;
        }
        [self.locationInitializer didFinishLaunching];
    };
}

- (InitializerCallback)locationCallback {
    return ^(NSError *error) {
        if (error) {
            self.callback(error);
            return;
        }
        self.callback(nil);
    };
}

@end
