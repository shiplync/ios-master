//
//  TRPhoneNumberFormatter.m
//  Impaqd
//
//  Created by Traansmission on 5/20/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRPhoneNumberFormatter.h"

@interface TRPhoneNumberFormatter ()

@property (nonatomic) NBPhoneNumberUtil *phoneNumberUtil;

@end

@implementation TRPhoneNumberFormatter

#pragma mark - NSFormatter Methods

- (NSString *)stringForObjectValue:(id)anObject {
    if (![anObject isKindOfClass:[NBPhoneNumber class]]) {
        return nil;
    }
    NBPhoneNumber *phoneNumber = (NBPhoneNumber *)anObject;
    if (self.phoneNumberStyle == PhoneNumberFormatterStyleNationalNumbersOnly) {
        return [[phoneNumber nationalNumber] stringValue];
    }
    return [self.phoneNumberUtil format:phoneNumber numberFormat:[self phoneNumberFormat] error:nil];
}

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject
                                 withDefaultAttributes:(NSDictionary *)attributes {
    NSString *string = [self stringForObjectValue:anObject];
    if  (string == nil) {
        return nil;
    }
    return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

- (NSString *)editingStringForObjectValue:(id)anObject {
    return [self stringForObjectValue:anObject];
}

- (BOOL)getObjectValue:(out id *)anObject
             forString:(NSString *)string
      errorDescription:(out NSString **)error {
    NSError *err;
    *anObject = [self.phoneNumberUtil parse:string defaultRegion:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] error:&err];
    if (err) {
        *error = [err localizedDescription];
    }
    return (*anObject != nil);
}

- (BOOL)isPartialStringValid:(NSString *)partialString
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)error {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ not implemented in %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
              originalString:(NSString *)origString
       originalSelectedRange:(NSRange)origSelRange
            errorDescription:(NSString **)error {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ not implemented in %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

#pragma mark - Public Class Methods

+ (instancetype)defaultFormatter {
    static TRPhoneNumberFormatter *_defaultInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultInstance = [[TRPhoneNumberFormatter alloc] init];
        [_defaultInstance setPhoneNumberStyle:PhoneNumberFormatterStyleNational];
    });
    return _defaultInstance;
}

- (NBPhoneNumber *)phoneNumberFromString:(NSString *)string {
    if (string == nil) {
        return nil;
    }
    NBPhoneNumber *phoneNumber;
    BOOL parsed = [self getObjectValue:&phoneNumber forString:string errorDescription:nil];
    return parsed ? phoneNumber : nil;
}

- (NBPhoneNumber *)phoneNumberFromString:(NSString *)string error:(out NSError **)error {
    if (string == nil) {
        return nil;
    }
    return [self.phoneNumberUtil parse:string defaultRegion:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] error:error];
}

- (NSString *)stringFromPhoneNumber:(NBPhoneNumber *)phoneNumber {
    return [self stringForObjectValue:phoneNumber];
}

- (NSString *)stringFromPhoneNumber:(NBPhoneNumber *)phoneNumber phoneNumberStyle:(enum PhoneNumberFormatterStyle)phoneNumberStyle {
    return [self stringFromPhoneNumber:phoneNumber phoneNumberStyle:phoneNumberStyle error:nil];
}

- (NSString *)stringFromPhoneNumber:(NBPhoneNumber *)phoneNumber phoneNumberStyle:(enum PhoneNumberFormatterStyle)phoneNumberStyle error:(out NSError **)error {
    if (phoneNumber == nil) {
        return nil;
    }
    enum PhoneNumberFormatterStyle oldStyle = self.phoneNumberStyle;
    [self setPhoneNumberStyle:phoneNumberStyle];
    NSString *string = [self.phoneNumberUtil format:phoneNumber numberFormat:[self phoneNumberFormat] error:error];
    [self setPhoneNumberStyle:oldStyle];
    return string;
}

#pragma mark - Private Property Overrides

- (NBPhoneNumberUtil *)phoneNumberUtil {
    if (_phoneNumberUtil == nil) {
        _phoneNumberUtil = [[NBPhoneNumberUtil alloc] init];
    }
    return _phoneNumberUtil;
}

#pragma mark - Private Methods 

- (NBEPhoneNumberFormat)phoneNumberFormat {
    NBEPhoneNumberFormat format = NBEPhoneNumberFormatE164;
    switch (self.phoneNumberStyle) {
        case PhoneNumberFormatterStyleNational:
        case PhoneNumberFormatterStyleNationalNumbersOnly:
            format = NBEPhoneNumberFormatNATIONAL;
            break;
            
        case PhoneNumberFormatterStyleInternational:
            format = NBEPhoneNumberFormatINTERNATIONAL;
            break;

        case PhoneNumberFormatterStyleRFC3966:
            format = NBEPhoneNumberFormatRFC3966;
            break;
            
        case PhoneNumberFormatterStyleE164:
            format = NBEPhoneNumberFormatE164;
            break;
    }
    return format;
}

@end
