//
//  VersionInitializer.m
//  Impaqd
//
//  Created by Traansmission on 4/22/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "VersionInitializer.h"
#import "TraansmissionKit.h"
#import "APISessionManager.h"

@interface VersionInitializer ()

@property (copy) InitializerCallback callback;
@property (nonatomic, copy) NSString *version;

@end

@implementation VersionInitializer

- (instancetype)initWithCallback:(InitializerCallback)callback {
    NSParameterAssert(callback);
    
    self = [super init];
    if (self) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        self.version = infoDictionary[@"CFBundleShortVersionString"];
        self.callback = callback;
    }
    return self;
}

- (void)didFinishLaunching {
    [self checkVersion];
}

- (void)willEnterForeground {
    [self checkVersion];
}

- (void)didEnterBackground {
}

#pragma mark - Private Instance Methods

- (void)checkVersion {
    [[APISessionManager sharedManager] checkVersion:self.version
                                         parameters:nil
                                            success:[self _successCallback]
                                            failure:[self _failureCallback]];
}

- (APISessionSuccessBlock)_successCallback {
    return ^(NSURLSessionDataTask *dataTask, id responseObject) {
        NSError *error;
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        BOOL versionOK = [responseDict[@"version_ok"] boolValue];
        if (!versionOK) {
            error = [NSError errorWithDomain:TRErrorDomain code:TRErrorVersionCheckFailed userInfo:nil];
        }
        self.callback(error);
    };
}

- (APISessionFailureBlock)_failureCallback {
    return ^(NSURLSessionDataTask *dataTask, NSError *error) {
        self.callback(error);
    };
}

@end
