//
//  TRMTLModel.m
//  Impaqd
//
//  Created by Traansmission on 6/11/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRMTLModel.h"
#import "TRPhoneNumberFormatter.h"

@implementation TRMTLModel

#pragma mark - MTLModel Class Method Overrides

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ not implemented in %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}


#pragma mark - Public Class Methods

+ (NSValueTransformer *)NSDateJSONTransformer {
    return [MTLValueTransformer
            transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
                NSDate *result = [self.dateFormatter dateFromString:(NSString *)value];
                if (result == nil) {
                    result = [self.dateFormatterWithMilliseconds dateFromString:(NSString *)value];
                }
                *success = (value != nil) ? (result != nil) : YES;
                *error = nil;
                return result;
            }
            reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
                *success = YES;
                *error = nil;
                NSString *result = [self.dateFormatterWithMilliseconds stringFromDate:(NSDate *)value];
                return result;
            }];
}

+ (NSValueTransformer *)NSNumberToBOOLJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{ @0 : @(NO),
                                                                            @1 : @(YES) }];
}

+ (NSValueTransformer *)NSTimeZoneJSONTransformer {
    return [MTLValueTransformer
            transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
                *success = YES;
                *error = nil;
                return [NSTimeZone timeZoneWithName:(NSString *)value];
            }
            reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
                *success = YES;
                *error = nil;
                return [(NSTimeZone *)value name];
            }];
}

+ (NSValueTransformer *)NSURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)NSUUIDJSONTransformer {
    return [MTLValueTransformer
            transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
                *success = YES;
                *error = nil;
                return [[NSUUID alloc] initWithUUIDString:(NSString *)value];
            }
            reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
                *success = YES;
                *error = nil;
                return [(NSUUID *)value UUIDString];
            }];
}


+ (NSValueTransformer *)PhoneNumberJSONTransformer {
    return [MTLValueTransformer
            transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
                NBPhoneNumber *phoneNumber = [[TRPhoneNumberFormatter defaultFormatter] phoneNumberFromString:value error:error];
                *success = true;
                return phoneNumber;
            }
            reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
                NSString *phoneString = [[TRPhoneNumberFormatter defaultFormatter] stringFromPhoneNumber:value phoneNumberStyle:PhoneNumberFormatterStyleE164];
                *success = true;
                return phoneString;
            }];
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}

+ (NSDateFormatter *)dateFormatterWithMilliseconds {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    return dateFormatter;
}

@end
