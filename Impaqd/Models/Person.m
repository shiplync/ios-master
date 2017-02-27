//
//  Person.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 2/29/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "Person.h"

@implementation Person

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"firstName"      : @"first_name",
              @"lastName"       : @"last_name",
              @"name"           : @"name",
              @"phone"          : @"phone",
              @"email"          : @"email",};
}

//+ (NSValueTransformer *)fleetJSONTransformer {
//    return [self NSNumberToBOOLJSONTransformer];
//}
//
//+ (NSValueTransformer *)rejectedJSONTransformer {
//    return [self NSNumberToBOOLJSONTransformer];
//}
//
//+ (NSValueTransformer *)verifiedJSONTransformer {
//    return [self NSNumberToBOOLJSONTransformer];
//}

//+ (NSValueTransformer *)phoneJSONTransformer {
//    return [self PhoneNumberJSONTransformer];
//}

@end