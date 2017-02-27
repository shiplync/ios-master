//
//  PayoutInfo.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 3/2/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "PayoutInfo.h"

@implementation PayoutInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"payout"             : @"payout",
              @"payoutDistance"     : @"payout_distance"};
}

- (NSString*)formattedPayout
{
    if (self.payout) {
        NSString *fmtString = @"$%.2f";
        return [NSString stringWithFormat:fmtString, self.payout.floatValue];
    } else {
        return nil;
    }
}

- (NSNumber*)convertedPayoutDistance
{
    // Hard coded to return value in miles.
    // TODO: Make compatible with other lenght measures (km).
    if (self.payoutDistance) {
        return [NSNumber numberWithDouble:self.payoutDistance.doubleValue * 1609.344];
    } else {
        return nil;
    }
}

- (NSString*)formattedPayoutDistance
{
    if (self.payoutDistance) {
        NSString *fmtString = @"$%.2f";
        return [NSString stringWithFormat:fmtString, [self convertedPayoutDistance].floatValue];
    } else {
        return nil;
    }
}

@end