//
//  AccountInitializer.m
//  Impaqd
//
//  Created by Traansmission on 4/22/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "AccountInitializer.h"
#import "AccountController.h"

@interface AccountInitializer ()

@property (copy) InitializerCallback callback;

@end

@implementation AccountInitializer

- (instancetype)initWithCallback:(InitializerCallback)callback {
    NSParameterAssert(callback);
    
    self = [super init];
    if (self) {
        self.callback = callback;
    }
    return self;
}

- (void)didFinishLaunching {
    [self carrierSingle];
}

- (void)willEnterForeground {
    [self carrierSingle];
}

- (void)didEnterBackground {
}

#pragma mark - Private Instance Methods

- (void)carrierSingle {
    [[AccountController sharedInstance] usersSelfWithCompletion:self.callback];
}

@end
