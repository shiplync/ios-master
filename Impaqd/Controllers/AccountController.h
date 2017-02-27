//
//  AccountController.h
//  Impaqd
//
//  Created by Traansmission on 5/5/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"
#import "Account.h"
#import "Carrier.h"

@interface AccountController : NSObject

@property (nonatomic, readonly) id<AccountProtocol> account;
@property (nonatomic) NSString *accountToken;

+ (instancetype)sharedInstance;

- (id<AccountProtocol>)activeUserAccount;
- (void)updateActiveUserAccountFromStore:(NSUbiquitousKeyValueStore *)store;
- (void)setActiveUserAccount:(id<AccountProtocol>)account;

- (void)registerAccount:(id<AccountProtocol>)account completion:(TRControllerCallback)completion;
- (void)acceptTOSWithCompletion:(TRControllerCallback)completion;
- (void)loginWithParameters:(NSDictionary *)parameters completion:(TRControllerCallback)completion;
- (void)logoutWithCompletion:(TRControllerCallback)completion;
- (void)statusWithParameters:(NSDictionary *)parameters completion:(TRControllerCallback)completion;
- (void)usersSelfWithCompletion:(TRControllerCallback)completion;
- (void)localLogout;

@end
