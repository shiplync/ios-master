//
//  AccountController.m
//  Impaqd
//
//  Created by Traansmission on 5/5/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "AccountController.h"
#import "AvailableShipmentSearchParameters.h"
#import <Mixpanel/Mixpanel.h>
#import "APISessionManager.h"
#import "APIOperationManager.h"
#import "constants.h"

static NSString * const kAccountControllerDefaultsKey = @"TRAccountControllerDefaultsKey";

@interface AccountController ()

@property (nonatomic, readwrite) id<AccountProtocol> account;

- (void)saveAccount:(id<AccountProtocol>)account;

@end

@implementation AccountController

+ (instancetype)sharedInstance {
    static AccountController *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[AccountController alloc] init];
    });
    return __sharedInstance;
}


#pragma mark - Private Property Overrides

- (void)setAccountToken:(NSString *)accountToken {
    _accountToken = accountToken;
    [[APIOperationManager sharedInstance] setToken:accountToken];
}


#pragma mark - Public Instance Methods

- (id<AccountProtocol>)activeUserAccount {
    if (self.account == nil) {
        [self migrateAccount];
        self.account = [self loadAccount];
    }
    return self.account;
}

- (void)updateActiveUserAccountFromStore:(NSUbiquitousKeyValueStore *)store {
    NSDictionary *attrs = [store objectForKey:kUserAccountKey];
    [[NSUserDefaults standardUserDefaults] setValue:attrs forKey:kUserAccountKey];
    [self loadActiveUser];
}

- (void)setActiveUserAccount:(id<AccountProtocol>)account {
    self.account = account;
    [self saveAccount:self.account];
}

- (void)registerAccount:(id<AccountProtocol>)account completion:(TRControllerCallback)completion {
    [[APISessionManager sharedManager] carriersRegisterWithParameters:[account registrationParameters]
                                                              success:[self registerAccountSuccessWithCompletion:completion]
                                                              failure:[self registerAccountFailureWithCompletion:completion]];
    
}

- (void)acceptTOSWithCompletion:(TRControllerCallback)completion {
    [[APISessionManager sharedManager] postAcceptTOSWithParameters:nil
                                                           success:[self acceptTOSSuccessWithCompletion:completion]
                                                           failure:[self acceptTOSFailureWithCompletion:completion]];
}

- (void)loginWithParameters:(NSDictionary *)parameters completion:(TRControllerCallback)completion {
    [[APISessionManager sharedManager] loginWithParameters:parameters
                                                   success:[self loginSuccessWithCompletion:completion]
                                                   failure:[self loginFailureWithCompletion:completion]];
}

- (void)logoutWithCompletion:(TRControllerCallback)completion {

    self.account = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *token = [defaults objectForKey:@"device_token"];
	
	//probably due to notification isn't enabled
	if(!token) {
		[self localLogout];
		if(completion){
			completion(nil);
		}
		return;
	}
	
	[[APISessionManager sharedManager] getPlatformIdWithToken:token
												   parameters:nil
													  success:[self getPlatformIdSuccess:completion]
													  failure:[self getPlatformIdFailure:completion]];
}

- (APISessionSuccessBlock) removeDeviceTokenSuccess:(TRControllerCallback)completion {
	
	return ^(NSURLSessionDataTask *task, id responseObject) {
		[self localLogout];
		if (completion) {
			completion(nil);
		}
		
	};
}

- (void) localLogout {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:kUserAccountKey];
	[defaults removeObjectForKey:kAccountControllerDefaultsKey];
	
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	if (store) {
		[store removeObjectForKey:kAccountControllerDefaultsKey];
	}
	
	[[APIOperationManager sharedInstance] clearToken];
	[[APISessionManager sharedManager] resetAuthenticatedRequestSerializer];
}



- (APISessionFailureBlock)removeDeviceTokenFailure:(TRControllerCallback)completion {
	return ^(NSURLSessionDataTask *task, NSError *error) {
		NSLog(@"Unable to remove device token: %@", error.localizedDescription);
		if (completion) {
			completion(error);
		}
	};
}

- (APISessionFailureBlock)getPlatformIdFailure:(TRControllerCallback)completion {
	return ^(NSURLSessionDataTask *task, NSError *error) {
		NSLog(@"Unable to get platform id: %@", error.localizedDescription);
		if (completion) {
			completion(error);
		}
	};
}

- (APISessionSuccessBlock)getPlatformIdSuccess:(TRControllerCallback)completion {
	return ^(NSURLSessionDataTask *task, id responseObject) {
		
		NSMutableArray *mutJSONNSArray = [(NSArray *)responseObject mutableCopy];

		//probably due to failed registration of token
		if([mutJSONNSArray count] == 0){
			[self localLogout];
			if(completion){
				completion(nil);
			}
			return;
		}
		
		NSMutableDictionary *mutJSONDictionary = (NSMutableDictionary *) mutJSONNSArray[0];
		NSInteger i_platform_id = [mutJSONDictionary[@"id"] integerValue];
		NSString *platform_id = [@(i_platform_id) stringValue];
		[[APISessionManager sharedManager] removeDeviceTokenWithId:platform_id
														parameters:nil
														   success:[self removeDeviceTokenSuccess:completion]
														   failure:[self removeDeviceTokenFailure:completion]];
	};
}


- (void)statusWithParameters:(NSDictionary *)parameters completion:(TRControllerCallback)completion {
    [[APISessionManager sharedManager] carriersStatusWithParameters:nil
                                                            success:[self carriersStatusSuccessWithCompletion:completion]
                                                            failure:[self carriersStatusFailureWithCompletion:completion]];
}

- (void)usersSelfWithCompletion:(TRControllerCallback)completion {
    [[APISessionManager sharedManager] usersSelfParameters:nil
                                                                   success:[self usersSelfSuccessWithCompletion:completion]
                                                                   failure:[self usersSelfFailureWithCompletion:completion]];
}


#pragma mark - Private Instance Methods

- (void)saveAccount:(id<AccountProtocol>)account {
    NSData *accountData = [NSKeyedArchiver archivedDataWithRootObject:self.account];
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accountData forKey:kAccountControllerDefaultsKey];
	
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    if (store) {
        [store setObject:accountData forKey:kAccountControllerDefaultsKey];
    }
}

- (void)migrateAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kAccountControllerDefaultsKey]) {
        return;
    }
    
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    if (store) {
        [store removeObjectForKey:kUserAccountKey];
    }
    
    Account *defaultsAccount = [self loadActiveUser];
    if (defaultsAccount) {
        [self saveAccount:defaultsAccount];
    }
}

- (id<AccountProtocol>)loadAccount {
    NSData *accountData = [[NSUserDefaults standardUserDefaults] objectForKey:kAccountControllerDefaultsKey];
    id<AccountProtocol> defaultsAccount = [NSKeyedUnarchiver unarchiveObjectWithData:accountData];
    return defaultsAccount;
}

- (id<AccountProtocol>)loadActiveUser {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *attrs = [defaults dictionaryForKey:kUserAccountKey];
    Account *defaultsAccount;
    if (attrs) {
        defaultsAccount = [[Account alloc] init];
        defaultsAccount.serverId = attrs[@"serverId"]; //If exists
        defaultsAccount.companyName = attrs[@"companyName"];
        defaultsAccount.licenseNumber = attrs[@"licenseNumber"];
        defaultsAccount.firstName = attrs[@"firstName"];
        defaultsAccount.lastName = attrs[@"lastName"];
        defaultsAccount.phoneNumber = attrs[@"phoneNumber"];
        defaultsAccount.isServerVerified = [attrs[@"isServerVerified"] boolValue];
        defaultsAccount.emailAddress = attrs[@"emailAddress"];
        
        defaultsAccount.photoBase64 = attrs[@"photoBase64"];
        if (defaultsAccount.photoBase64 == nil) {
            defaultsAccount.photoBase64 = attrs[@"profilePhoto"];
        }
    }
    return defaultsAccount;
}

- (APISessionSuccessBlock)registerAccountSuccessWithCompletion:(TRControllerCallback)completion {
    return ^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseData = (NSDictionary *)responseObject;
        NSString* token = responseData[@"token"];
        [[AccountController sharedInstance] setAccountToken:token];
        [self usersSelfWithCompletion:completion];
    };
}

- (APISessionFailureBlock)registerAccountFailureWithCompletion:(TRControllerCallback)completion {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        if (response.statusCode == 409) {
            error = [NSError errorWithCode:TRErrorRegistration
                               description:@"User already exists."
                                    reason:@"Please go back and change your email."];
        }
        else if (response.statusCode == 406) {
            error = [NSError errorWithCode:TRErrorRegistration
                               description:@"Registration Error"
                                    reason:error.userInfo[TRJSONResponseSerializerKey][@"error"]];
        }
        else {
            error = [NSError errorWithCode:TRErrorRegistration
                               description:@"Problem contacting server"
                                    reason:@"We're sorry, but we could not create your account at this time. Please try again."];
        }
        
        if (completion) {
            completion(error);
        }
    };
}

- (APISessionSuccessBlock)acceptTOSSuccessWithCompletion:(TRControllerCallback)completion {
    return ^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            completion(nil);
        }
    };
}

- (APISessionFailureBlock)acceptTOSFailureWithCompletion:(TRControllerCallback)completion {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(error);
        }
    };
}

- (APISessionSuccessBlock)loginSuccessWithCompletion:(TRControllerCallback)completion {
    return ^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        [self setAccountToken:responseDict[@"token"]];
        [self usersSelfWithCompletion:completion];
    };
}

- (APISessionFailureBlock)loginFailureWithCompletion:(TRControllerCallback)completion {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(error);
        }
    };
}

- (APISessionSuccessBlock)carriersStatusSuccessWithCompletion:(TRControllerCallback)completion {
    return ^(NSURLSessionDataTask *dataTask, id responseObject) {
        NSDictionary *responseDict = responseObject;
        NSNumber *verifiedNumber = responseDict[@"verified"];
        self.account.verified = [verifiedNumber boolValue];
        [self saveAccount:self.account];
        
        if (completion) {
            completion(nil);
        }
    };
}

- (APISessionFailureBlock)carriersStatusFailureWithCompletion:(TRControllerCallback)completion {
    return ^(NSURLSessionDataTask *dataTask, NSError *error) {
        if (completion) {
            completion(error);
        }
    };
}

- (APISessionSuccessBlock)usersSelfSuccessWithCompletion:(TRControllerCallback)completion {
    return ^(NSURLSessionDataTask *dataTask, id responseObject) {
        NSDictionary *responseData = (NSDictionary *)responseObject;
        NSError *error;
        Carrier *carrier = [MTLJSONAdapter modelOfClass:[Carrier class] fromJSONDictionary:responseData error:&error];
        [[AccountController sharedInstance] setActiveUserAccount:carrier];
        //ANALYTICS START
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        if(carrier.email){
            // Use dev token if user has a Traansmission email
            if ([carrier.email containsString:@"traansmission"]) {
                [Mixpanel sharedInstanceWithToken:kMixpanelInternalToken];
            }
            [mixpanel identify:carrier.email];
        }
        [mixpanel track:@"launched ios app"];
        //ANALYTICS END
        if (completion) {
            completion(error);
        }
    };
}

- (APISessionFailureBlock)usersSelfFailureWithCompletion:(TRControllerCallback)completion {
    return ^(NSURLSessionDataTask *dataTask, NSError *error) {
        if (completion) {
            completion(error);
        }
    };
}

@end
