//
//  Account.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/22/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "Account.h"
#import "APIOperationManager.h"
#import "sharedConstants.h"
#import "AvailableShipmentSearchParameters.h"
#import <SSKeychain/SSKeychain.h>

#import "APISessionManager.h"

static Account *_userAccount;
NSString * const kUserAccountKey = @"activeUserAccount";

// TODO: Considering redesigning this class so the singleton active user doesn't get overwritten
//       with a new object in +loadActiveUser. This could be a problem if iCloud sends an update
//       in the middle of a run and there's a stale reference to the old account being retained.

@implementation Account

#pragma mark - AccountProtocol Properties

- (NSNumber *)traansmissionId {
    return [NSNumber numberWithInteger:[self.serverId integerValue]];
}

- (void)setTraansmissionId:(NSNumber *)traansmissionId {
    self.serverId = [traansmissionId stringValue];
}

- (NSString *)email {
    return self.emailAddress;
}

- (void)setEmail:(NSString *)email {
    self.emailAddress = email;
}

// phoneNumber maps to existing property
// firstName maps to existing property
// lastName maps to existing property

- (BOOL)isVerified {
    return self.isServerVerified;
}

- (void)setVerified:(BOOL)verified {
    self.isServerVerified = verified;
}

- (NSURL *)profileImageURL {
    return nil;
}

- (void)setProfileImageURL:(NSURL *)profileImageURL {
    return;
}

// companyName maps to existing property

- (NSNumber *)dotNumber {
    return [NSNumber numberWithInteger:[self.licenseNumber integerValue]];
}

- (void)setDotNumber:(NSNumber *)dotNumber {
    self.licenseNumber = [dotNumber stringValue];
}

@synthesize vehicleType = _vehicleType;

- (NSString *)phoneNumberE164 {
    return [[TRPhoneNumberFormatter defaultFormatter] stringFromPhoneNumber:self.phoneNumber phoneNumberStyle:PhoneNumberFormatterStyleE164];
}

- (NSString *)phoneNumberNational {
    return [[TRPhoneNumberFormatter defaultFormatter] stringFromPhoneNumber:self.phoneNumber phoneNumberStyle:PhoneNumberFormatterStyleNationalNumbersOnly];
}

#pragma mark - NSCoding Protocol Methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.serverId = [aDecoder decodeObjectForKey:@"serverId"];
        self.emailAddress = [aDecoder decodeObjectForKey:@"emailAddress"];
        self.password = [aDecoder decodeObjectForKey:@"password"];
        self.companyName = [aDecoder decodeObjectForKey:@"companyName"];
        self.firstName = [aDecoder decodeObjectForKey:@"firstName"];
        self.lastName = [aDecoder decodeObjectForKey:@"lastName"];

        self.phoneNumber = [aDecoder decodeObjectForKey:@"phoneNumber"];
        if (self.phoneNumber == nil) {
            self.phoneNumber = [[TRPhoneNumberFormatter defaultFormatter] phoneNumberFromString:[aDecoder decodeObjectForKey:@"phone"]];
        }
        
        self.licenseNumber = [aDecoder decodeObjectForKey:@"licenseNumber"];
        self.photo = [aDecoder decodeObjectForKey:@"photo"];
        
        self.photoBase64 =[aDecoder decodeObjectForKey:@"profilePhoto"];
        if (self.photoBase64 == nil) {
            self.photoBase64 = [aDecoder decodeObjectForKey:@"photoBase64"];
        }
        
        NSNumber *verifiedNumber = [aDecoder decodeObjectForKey:@"verifiedNumber"];
        self.isServerVerified = [verifiedNumber boolValue];
        
        NSNumber *vehicleTypeNumber = [aDecoder decodeObjectForKey:@"vehicleTypeNumber"];
        self.vehicleType = VehicleTypeFromNSNumber(vehicleTypeNumber);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.serverId forKey:@"serverId"];
    [aCoder encodeObject:self.emailAddress forKey:@"emailAddress"];
    [aCoder encodeObject:self.password forKey:@"password"];
    [aCoder encodeObject:self.companyName forKey:@"companyName"];
    [aCoder encodeObject:self.firstName forKey:@"firstName"];
    [aCoder encodeObject:self.lastName forKey:@"lastName"];
    [aCoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
    [aCoder encodeObject:self.licenseNumber forKey:@"licenseNumber"];
    [aCoder encodeObject:self.photoBase64 forKey:@"photoBase64"];
    [aCoder encodeObject:self.photo forKey:@"photo"];
    
    NSNumber *verifiedNumber = [NSNumber numberWithInt:self.isServerVerified];
    [aCoder encodeObject:verifiedNumber forKey:@"verifiedNumber"];

    NSNumber *vehicleTypeNumber = NSNumberFromVehicleType(self.vehicleType);
    [aCoder encodeObject:vehicleTypeNumber forKey:@"vehicleTypeNumber"];
}

#pragma mark - NSCopying Protocol Methods

- (instancetype)copyWithZone:(NSZone *)zone {
    Account *account = [[Account allocWithZone:zone] init];
    account.serverId = self.serverId;
    account.emailAddress = self.emailAddress;
    account.password = self.password;
    account.companyName = self.companyName;
    account.firstName = self.firstName;
    account.lastName = self.lastName;
    account.phoneNumber = self.phoneNumber;
    account.licenseNumber = self.licenseNumber;
    account.photoBase64 = self.photoBase64;
    account.photo = self.photo;
    account.isServerVerified = self.isServerVerified;
    account.vehicleType = self.vehicleType;
    return account;
}

#pragma mark - NSObject Equality Methods

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[Account class]]) {
        return NO;
    }
    
    Account *account = (Account *)object;
    return ([self.serverId isEqualToString:account.serverId]
            && [self.emailAddress isEqualToString:account.emailAddress]
            && ((self.password == nil && account.password == nil) || [self.password isEqualToString:account.password])
            && ((self.companyName == nil && account.companyName == nil) || [self.companyName isEqualToString:account.companyName])
            && [self.firstName isEqualToString:account.firstName]
            && [self.lastName isEqualToString:account.lastName]
            && [self.phoneNumber isEqual:account.phoneNumber]
            && [self.licenseNumber isEqualToString:account.licenseNumber]
            && self.isServerVerified == account.isServerVerified
            && self.vehicleType == account.vehicleType);
}

- (NSUInteger)hash {
    return self.serverId.hash;
}

#pragma mark - Initializers

//This block is called from RegistrationReviewViewController when the
//Account has been successfully created on server.
- (instancetype)initWithServerResponse:(NSDictionary *)attrs
{
    self = [super init];
    if (self) {
        NSMutableDictionary *mutAttrs = [attrs mutableCopy];
        [mutAttrs removeObjectsForKeys:[mutAttrs allKeysForObject:[NSNull null]]];

        self.companyName = mutAttrs[@"companyName"];
        self.licenseNumber = mutAttrs[@"mcdot"];
        self.firstName = mutAttrs[@"first_name"];
        self.lastName = mutAttrs[@"last_name"];

        self.isServerVerified = [mutAttrs[@"verified"] boolValue];
        self.photoBase64 = mutAttrs[@"photo"];
        self.emailAddress = mutAttrs[@"email"];

        self.phoneNumber = [[TRPhoneNumberFormatter defaultFormatter] phoneNumberFromString:mutAttrs[@"phone"]];

        NSNumber *typeNumber = [NSNumber numberWithInteger:[attrs[@"vehicle_type"] integerValue]];
        VehicleType vehicleType = VehicleTypeFromNSNumber(typeNumber);
        [[AvailableShipmentSearchParameters sharedInstance] setVehicleType:vehicleType];
    }
    return self;
}

- (instancetype)initWithNestedJSONDictionary:(NSDictionary *)jsonDictionary {
    self = [super init];
    if (self) {
        [self parseCarrierJSONDictionary:jsonDictionary];
        [self parseCompanyJSONDictionary:[jsonDictionary objectForKey:@"company"]];
    }
    return self;
}

#pragma mark - Property Overrides

- (VehicleType)vehicleType {
    return [[AvailableShipmentSearchParameters sharedInstance] vehicleType];
}

- (void)setVehicleType:(enum VehicleType)vehicleType {
    _vehicleType = vehicleType;
    [[AvailableShipmentSearchParameters sharedInstance] setVehicleType:vehicleType];
}

#pragma mark - Public Instance Methods

- (NSDictionary *)registrationParameters {
    NSString *phoneString = [[TRPhoneNumberFormatter defaultFormatter] stringFromPhoneNumber:self.phoneNumber phoneNumberStyle:PhoneNumberFormatterStyleE164];
    NSMutableDictionary *userDictionary = [NSMutableDictionary dictionaryWithDictionary:@{ @"email"        : self.emailAddress,
                                                                                           @"password"     : self.password,
                                                                                           @"phone"        : phoneString,
                                                                                           @"first_name"   : self.firstName,
                                                                                           @"last_name"    : self.lastName }];
    NSDictionary *dictionary = @{ @"user"           : userDictionary,
                                  @"company"        : @{ @"company_name" : self.companyName,
                                                         @"dot"          : self.licenseNumber,
                                                         @"is_fleet"     : @(NO) },
                                  @"carrier_driver" : @{ @"vehicle_type" : NSNumberFromVehicleType(self.vehicleType),
                                                         @"phone"        : phoneString,
                                                         @"first_name"   : self.firstName,
                                                         @"last_name"    : self.lastName }
                                  };
    return dictionary;
}

- (NSDictionary *)patchParameters {
    NSNumber *vehicleNumber = NSNumberFromVehicleType(self.vehicleType);
    NSMutableDictionary *params = [ @{ @"first_name"   : self.firstName,
                                       @"last_name"    : self.lastName,
                                       @"phone"        : self.phoneNumberE164,
                                       @"email"        : self.email,
                                       @"vehicle_type" : vehicleNumber } mutableCopy];
    NSString *companyString = self.companyName ? self.companyName : (NSString *)[NSNull null];
    params[@"company"] = @{ @"company_name" : companyString,
                            @"dot"          : self.dotNumber };
    return params;
}

#pragma mark - Private Instance Methods

- (void)parseCarrierJSONDictionary:(NSDictionary *)jsonDictionary {
    NSMutableDictionary *mutJSONDictionary = [jsonDictionary mutableCopy];
    [mutJSONDictionary removeObjectsForKeys:[mutJSONDictionary allKeysForObject:[NSNull null]]];
    
    self.serverId = [mutJSONDictionary[@"id"] description];
    self.emailAddress = mutJSONDictionary[@"email"];
    self.firstName = mutJSONDictionary[@"first_name"];
    self.lastName = mutJSONDictionary[@"last_name"];
    
    self.phoneNumber = [[TRPhoneNumberFormatter defaultFormatter] phoneNumberFromString:mutJSONDictionary[@"phone"]];

    self.photoBase64 = mutJSONDictionary[@"photo"];

    NSNumber *vehicleTypeNumber = [NSNumber numberWithInteger:[jsonDictionary[@"vehicle_type"] integerValue]];
    self.vehicleType = VehicleTypeFromNSNumber(vehicleTypeNumber);
    [[AvailableShipmentSearchParameters sharedInstance] setVehicleType:self.vehicleType];
}

- (void)parseCompanyJSONDictionary:(NSDictionary *)jsonDictionary {
    NSMutableDictionary *mutJSONDictionary = [jsonDictionary mutableCopy];
    [mutJSONDictionary removeObjectsForKeys:[mutJSONDictionary allKeysForObject:[NSNull null]]];

    self.companyName = mutJSONDictionary[@"company_name"];
    self.licenseNumber = [mutJSONDictionary[@"dot"] description];
    
    NSNumber *verifiedNumber = mutJSONDictionary[@"verified"];
    self.isServerVerified = [verifiedNumber boolValue];
}

@end
