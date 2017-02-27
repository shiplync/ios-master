//
//  Location.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 2/26/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "Location.h"
#import "HelperFunctions.h"

@implementation Location

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"traansmissionId" : @"id",
              @"locationType"    : @"location_type",
              @"companyName"     : @"company_name",
              @"addressDetails"  : @"address_details",
              @"contact"         : @"contact",
              @"features"        : @"features",
              @"timeRange"       : @"time_range",
              @"arrivalTime"     : @"arrival_time",
//              @"DOT"             : @"dot",
//              @"MC"              : @"mc",
//              @"insurance"       : @"insurance",
//              @"fleet"           : @"is_fleet",
//              @"maximumRequests" : @"max_requests",
//              @"rejected"        : @"rejected",
//              @"verified"        : @"verified",
              @"createdAt"       : @"created_at",
              @"updatedAt"       : @"updated_at" };
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

+ (NSValueTransformer *)locationTypeJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[LocationType class]];
}

+ (NSValueTransformer *)timeRangeJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[TimeRange class]];
}

+ (NSValueTransformer *)contactJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[Person class]];
}

+ (NSValueTransformer *)featuresJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ShipmentFeatures class]];
}

+ (NSValueTransformer *)addressDetailsJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[AddressDetails class]];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [self NSDateJSONTransformer];
}

+ (NSValueTransformer *)updatedAtJSONTransformer {
    return [self NSDateJSONTransformer];
}

+ (NSValueTransformer *)arrivalTimeJSONTransformer {
    return [self NSDateJSONTransformer];
}

- (NSString *)arrivalTimeDescription
{
    return [[HelperFunctions sharedInstance] getDateString:self.arrivalTime withTimeZone:self.timeRange.tz];
}

@end