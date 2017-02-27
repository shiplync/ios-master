//
//  TimeRange.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 3/2/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "TimeRange.h"
#import "HelperFunctions.h"

@implementation TimeRange

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"timeRangeStart"        : @"time_range_start",
              @"timeRangeEnd"          : @"time_range_end",
              @"tz"                    : @"tz"};
}

+ (NSValueTransformer *)timeRangeStartJSONTransformer {
    return [self NSDateJSONTransformer];
}

+ (NSValueTransformer *)timeRangeEndJSONTransformer {
    return [self NSDateJSONTransformer];
}

+ (NSValueTransformer *)tzJSONTransformer {
    return [self NSTimeZoneJSONTransformer];
}

- (NSString *)timeRangeStartDescription
{
    return [[HelperFunctions sharedInstance] getDateString:self.timeRangeStart withTimeZone:self.tz];
}

- (NSString *)timeRangeEndDescription
{
    return [[HelperFunctions sharedInstance] getDateString:self.timeRangeEnd withTimeZone:self.tz];
}

- (NSString *)timeRangeStartDescriptionDateOnly
{
    return [[HelperFunctions sharedInstance] getDateString:self.timeRangeStart withTimeZone:self.tz dateOnly:YES];
}

- (NSString *)timeRangeEndDescriptionDateOnly
{
    return [[HelperFunctions sharedInstance] getDateString:self.timeRangeEnd withTimeZone:self.tz dateOnly:YES];
}


@end