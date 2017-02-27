//
//  TokenInitializer.m
//  Impaqd
//
//  Created by Traansmission on 4/22/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TokenInitializer.h"
#import <SSKeychain/SSKeychain.h>
#import "sharedConstants.h"
#import "APISessionManager.h"

@interface TokenInitializer ()

@property (copy) InitializerCallback callback;
@property (nonatomic) NSTimer *timer;

@end

@implementation TokenInitializer

- (instancetype)initWithCallback:(InitializerCallback)callback {
    NSParameterAssert(callback);
    
    self = [super init];
    if (self) {
        self.callback = callback;
    }
    return self;
}

- (void)didFinishLaunching {
    [self verifyToken];
}

- (void)willEnterForeground {
    [self restartVerify];
}

- (void)didEnterBackground {
    [self resetTimer];
}

#pragma mark - Private Instance Methods

- (void)verifyToken {
    NSError *error;
    NSString *token = [SSKeychain passwordForService:TOKEN_LOGIN account:DEFAULT_ACCOUNT error:&error];
    if (token) {
        [[APISessionManager sharedManager] verifyTokenWithParameters:nil
                                                             success:[self _successCallback]
                                                             failure:[self _failureCallback]];
    }
    else {
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(restartVerify) userInfo:nil repeats:NO];
        }
        else {
            self.callback(error);
        }
    }
}

- (void)restartVerify {
    [self.timer invalidate];
    [self didFinishLaunching];
}

- (void)resetTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (APISessionSuccessBlock)_successCallback {
    return ^(NSURLSessionDataTask *dataTask, id responseObject) {
        self.callback(nil);
    };
}

- (APISessionFailureBlock)_failureCallback {
    return ^(NSURLSessionDataTask *dataTask, NSError *error) {
        [SSKeychain deletePasswordForService:TOKEN_LOGIN account:DEFAULT_ACCOUNT];
        self.callback(error);
    };
}

@end


