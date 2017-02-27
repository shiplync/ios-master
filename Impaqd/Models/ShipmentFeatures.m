//
//  ShipmentFeatures.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 3/1/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "ShipmentFeatures.h"

@implementation ShipmentFeatures

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"weight"                : @"weight",
              @"palletized"            : @"palletized",
              @"palletHeight"          : @"pallet_height",
              @"palletLength"          : @"pallet_length",
              @"palletWidth"           : @"pallet_width",
              @"palletNumber"          : @"pallet_number",};
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

- (NSString*)palletDimensions
{
    NSString *result = @"";
    if (self.palletHeight && self.palletHeight != [NSNull class]) {
        result = [result stringByAppendingFormat:@"H: %@ ", self.palletHeight];
    }
    if (self.palletWidth && self.palletWidth != [NSNull class]) {
        result = [result stringByAppendingFormat:@"W: %@ ", self.palletWidth];
    }
    if (self.palletLength && self.palletLength != [NSNull class]) {
        result = [result stringByAppendingFormat:@"L: %@ ", self.palletLength];
    }
    if (result.length) {
        return result;
    } else {
        return nil;
    }
}

- (BOOL)isPalletized
{
    return [self.palletized boolValue];
}



@end