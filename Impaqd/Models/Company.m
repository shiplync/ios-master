//
//  Company.m
//  Impaqd
//
//  Created by Traansmission on 5/6/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "Company.h"

@implementation Company

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"traansmissionId" : @"id",
              @"name"            : @"company_name",
              @"DOT"             : @"dot",
              @"MC"              : @"mc",
              @"insurance"       : @"insurance",
              @"fleet"           : @"is_fleet",
              @"maximumRequests" : @"max_requests",
              @"rejected"        : @"rejected",
              @"verified"        : @"verified",
              @"createdAt"       : @"created_at",
              @"updatedAt"       : @"updated_at" };
}

+ (NSValueTransformer *)fleetJSONTransformer {
    return [self NSNumberToBOOLJSONTransformer];
}

+ (NSValueTransformer *)rejectedJSONTransformer {
    return [self NSNumberToBOOLJSONTransformer];
}

+ (NSValueTransformer *)verifiedJSONTransformer {
    return [self NSNumberToBOOLJSONTransformer];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [self NSDateJSONTransformer];
}

+ (NSValueTransformer *)updatedAtJSONTransformer {
    return [self NSDateJSONTransformer];
}

@end
