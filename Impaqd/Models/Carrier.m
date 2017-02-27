//
//  Carrier.m
//  Impaqd
//
//  Created by Traansmission on 5/14/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "Carrier.h"

@implementation Carrier

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    return dateFormatter;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"traansmissionId" : @"id",
              @"userId"          : @"user",
              @"email"           : @"email",
              @"phoneNumber"     : @"phone",
              @"firstName"       : @"first_name",
              @"lastName"        : @"last_name",
              @"vehicleType"     : @"vehicle_type",
              @"company"         : @"company",
              @"profilePhoto"    : @"profile_photo",
              @"createdAt"       : @"created_at",
              @"updatedAt"       : @"updated_at" };
}

+ (NSValueTransformer *)phoneNumberJSONTransformer {
    return [self PhoneNumberJSONTransformer];
}

+ (NSValueTransformer *)companyJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[Company class]];
}

+ (NSValueTransformer *)profilePhotoJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ProfilePhoto class]];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [self NSDateJSONTransformer];
}

+ (NSValueTransformer *)updatedAtJSONTransformer {
    return [self NSDateJSONTransformer];
}

#pragma mark - NSObject Protocol Overrides

//- (BOOL)isEqual:(id)object {
//    if (![object isKindOfClass:[Carrier class]]) {
//        return NO;
//    }
//    Carrier *other = (Carrier *)object;
//    BOOL selfEqual = [super isEqual:other];
//    BOOL companyEqual = [self.company isEqual:other.company];
//    BOOL photoEqual = [self.profilePhoto isEqual:other.profilePhoto];
//    return selfEqual && companyEqual &&photoEqual;
//}

#pragma mark - Account Protocol

// traansmissionId maps to existing property
// email maps to existing property
// phoneNumber maps to existing property
// firstName maps to existing property
// lastName maps to existing property

- (BOOL)isVerified {
    return self.company.isVerified;
}

- (void)setVerified:(BOOL)verified {
    self.company.verified = verified;
}

- (NSString *)companyName {
    return self.company.name;
}

- (void)setCompanyName:(NSString *)companyName {
    self.company.name = companyName;
}

- (NSNumber *)dotNumber {
    return self.company.DOT;
}

- (void)setDotNumber:(NSNumber *)dotNumber {
    self.company.DOT = dotNumber;
}

// vehicleType maps to existing property

- (NSURL *)profileImageURL {
    return self.profilePhoto.URL;
}

- (NSString *)phoneNumberE164 {
    TRPhoneNumberFormatter *formatter = [TRPhoneNumberFormatter defaultFormatter];
    [formatter setPhoneNumberStyle:PhoneNumberFormatterStyleE164];
    return [formatter stringFromPhoneNumber:self.phoneNumber];
}

- (NSString *)phoneNumberNational {
    TRPhoneNumberFormatter *formatter = [TRPhoneNumberFormatter defaultFormatter];
    [formatter setPhoneNumberStyle:PhoneNumberFormatterStyleNationalNumbersOnly];
    return [formatter stringFromPhoneNumber:self.phoneNumber];
}

- (NSDictionary *)registrationParameters {
#warning Confirm this is correct
    return [MTLJSONAdapter JSONDictionaryFromModel:self error:nil];
}

- (NSDictionary *)patchParameters {
#warning Confirm this is correct
    return [MTLJSONAdapter JSONDictionaryFromModel:self error:nil];
}

#warning Remove this  - here due to Mantle bug
- (UIImage *)photo {
    return nil;
}

#warning Remove this  - here due to Mantle bug
- (void)setPhoto:(UIImage *)photo {
    return;    // NO-OP
}

@end
