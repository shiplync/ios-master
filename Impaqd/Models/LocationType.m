//
//  LocationType.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 2/29/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "LocationType.h"

@implementation LocationType

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"label"          : @"label",
              @"value"          : @"value"};
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