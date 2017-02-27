//
//  Account.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/22/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"
#import "AccountProtocol.h"

FOUNDATION_EXTERN NSString * const kUserAccountKey;

@interface Account : NSObject <NSCoding, NSCopying, AccountProtocol>

@property (nonatomic, copy) NSString      *serverId;
@property (nonatomic, copy) NSString      *emailAddress;
@property (nonatomic, copy) NSString      *password;
@property (nonatomic, copy) NSString      *companyName;
@property (nonatomic, copy) NSString      *firstName;
@property (nonatomic, copy) NSString      *lastName;
@property (nonatomic, copy) NBPhoneNumber *phoneNumber;
@property (nonatomic, copy) NSString      *licenseNumber;

@property (nonatomic, assign) BOOL isServerVerified;
@property (nonatomic, copy) NSString *photoBase64;
@property (nonatomic, copy) UIImage  *photo;
@property (nonatomic, copy) ProfilePhoto  *profilePhoto;

@property (nonatomic, assign) enum VehicleType vehicleType;

- (instancetype)initWithServerResponse:(NSDictionary *)attrs;
- (instancetype)initWithNestedJSONDictionary:(NSDictionary *)jsonDictionary;

- (NSDictionary *)registrationParameters;
- (NSDictionary *)patchParameters;

@end
