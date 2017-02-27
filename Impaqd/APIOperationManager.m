//
//  APIOperationManager.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/23/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "APIOperationManager.h"
#import "constants.h"
#import <SSKeychain/SSKeychain.h>
#import "sharedConstants.h"
#import "TRJSONResponseSerializer.h"
#import "APISessionManager.h"


@implementation APIOperationManager

//IMPORTANT: ALWAYS CALL SHARED INSTANCE BEFORE USING THE CLASS,
//AS THE SERIALIZERS MIGHT HAVE CHANGED IN BETWEEN OTHERWISE. 
+ (instancetype)sharedInstance
{
    static APIOperationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[APIOperationManager alloc] init];
    });
    [sharedManager setSerializers]; 
    return sharedManager;
}

- (id)init
{
    self = [super initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    return self;
}

- (void)setSerializers
{
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer new];
        self.responseSerializer = [TRJSONResponseSerializer new];
        NSString* token = [SSKeychain passwordForService:TOKEN_LOGIN account:DEFAULT_ACCOUNT];
        if(token){
            [self.requestSerializer setValue:[NSString stringWithFormat:@"Token %@",token] forHTTPHeaderField:@"Authorization"];
        }
    }
}

- (void)setToken:(NSString*)token
{
    [self clearToken];
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Token %@",token] forHTTPHeaderField:@"Authorization"];
    [SSKeychain setPassword:token forService:TOKEN_LOGIN account:DEFAULT_ACCOUNT];
}

- (void)clearToken
{
    [SSKeychain deletePasswordForService:TOKEN_LOGIN account:DEFAULT_ACCOUNT];
    self.requestSerializer = [AFJSONRequestSerializer new];
    [[APISessionManager sharedManager] resetAuthenticatedRequestSerializer];
}

@end
