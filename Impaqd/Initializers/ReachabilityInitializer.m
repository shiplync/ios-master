//
//  ReachabilityInitializer.m
//  Impaqd
//
//  Created by Traansmission on 4/24/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "ReachabilityInitializer.h"
#import "APISessionManager.h"
#import "TraansmissionKit.h"

@interface ReachabilityInitializer ()

@property (copy) InitializerCallback callback;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic) NSTimer *timer;

@end

@implementation ReachabilityInitializer

- (instancetype)initWithCallback:(InitializerCallback)callback {
    NSParameterAssert(callback);
    
    self = [super init];
    if (self) {
        self.callback = callback;
    }
    return self;
}

- (void)didFinishLaunching {
    [self startMonitoring];
}

- (void)willEnterForeground{
    [self startMonitoring];
}

- (void)didEnterBackground {
    [[[APISessionManager sharedManager] reachabilityManager] stopMonitoring];
}

#pragma mark - NSErrorRecoveryAttempting (Informal) Protocol

- (BOOL)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex {
    BOOL success = NO;
    switch (recoveryOptionIndex) {
        case 0:    // Try Again
            success = YES;
            [self startMonitoring];
            break;
            
        case 1:    // OK
            success = YES;
            break;
            
        default:
            break;
    }
    return success;
}


#pragma mark - Private Instance Methods

- (void)startMonitoring {
    AFNetworkReachabilityManager *manager = [[APISessionManager sharedManager] reachabilityManager];
    [manager setReachabilityStatusChangeBlock:[self reachabilityChangedBlock]];
    [manager startMonitoring];
    self.timer = [NSTimer timerWithTimeInterval:10.0f target:self selector:@selector(serverNotReachable:) userInfo:nil repeats:NO];
}

- (void (^)(AFNetworkReachabilityStatus status))reachabilityChangedBlock {
    return ^(AFNetworkReachabilityStatus status) {
        [self.timer invalidate];
        self.timer = nil;
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                [self serverNotReachable:self];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [[[APISessionManager sharedManager] reachabilityManager] setReachabilityStatusChangeBlock:nil];
                if (self.callback) {
                    self.callback(nil);
                }
                break;
        }
    };
}

- (void)serverNotReachable:(id)sender {
    [[[APISessionManager sharedManager] reachabilityManager] stopMonitoring];
    NSError *error = [NSError URLCannotConnectToHostWithAttempter:self];
    self.callback(error);
}

@end
