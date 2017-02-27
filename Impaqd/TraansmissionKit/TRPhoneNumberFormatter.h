//
//  TRPhoneNumberFormatter.h
//  Impaqd
//
//  Created by Traansmission on 5/20/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libPhoneNumber-iOS/NBPhoneNumber.h>
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>

NS_ENUM(NSInteger, PhoneNumberFormatterStyle) {
    PhoneNumberFormatterStyleNational,               // (###) ###-####
    PhoneNumberFormatterStyleInternational,          // +# ###-###-####
    PhoneNumberFormatterStyleRFC3966,                // tel: +#-###-###-####
    PhoneNumberFormatterStyleE164,                   // +###########
    PhoneNumberFormatterStyleNationalNumbersOnly,    // ##########
};

@interface TRPhoneNumberFormatter : NSFormatter

@property (nonatomic) enum PhoneNumberFormatterStyle phoneNumberStyle;

+ (instancetype)defaultFormatter;
- (NBPhoneNumber *)phoneNumberFromString:(NSString *)string;
- (NBPhoneNumber *)phoneNumberFromString:(NSString *)string error:(out NSError **)error;

- (NSString *)stringFromPhoneNumber:(NBPhoneNumber *)phoneNumber;
- (NSString *)stringFromPhoneNumber:(NBPhoneNumber *)phoneNumber phoneNumberStyle:(enum PhoneNumberFormatterStyle)phoneNumberStyle;
- (NSString *)stringFromPhoneNumber:(NBPhoneNumber *)phoneNumber phoneNumberStyle:(enum PhoneNumberFormatterStyle)phoneNumberStyle error:(out NSError **)error;

@end
