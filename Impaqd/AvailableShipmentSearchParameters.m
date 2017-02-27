//
//  AvailableShipmentSearchOptions.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/24/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "AvailableShipmentSearchParameters.h"
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import "Shipment.h"
#import "AccountController.h"

// used in `updateTimeParameters` below
// We change default time window from 1 day to 5 days, so we don't see empty maps when there is only few shipments.
const NSTimeInterval DEFAULT_TIME_WINDOW = 5 * 24 * 60 * 60;
const NSTimeInterval MINIMUM_TIME_WINDOW = 6 * 60 * 60;

@implementation AvailableShipmentSearchParameters

+ (instancetype)sharedInstance
{
    static AvailableShipmentSearchParameters *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AvailableShipmentSearchParameters new];
        instance.vehicleType = [[[AccountController sharedInstance] account] vehicleType];
        instance.maximumTripDistance = 3000;
        instance.minimumPayoutUSD = [NSDecimalNumber decimalNumberWithString:@"300.00"];
        instance.searchRadius = 900 * 1609.34; // 100 miles originally
        [instance updateTimeParameters];    // initialize time params
    });
    return instance;
}

- (void)updateTimeParameters
{
    // if the earliest pick up time is in the past, update it to now
    if (!self.pickUpTime || [self.pickUpTime timeIntervalSinceNow] < 0) {
        self.pickUpTime = [NSDate date];
    }
    
    // if the delivery time and pick up time is smaller than the min time window inflate it to the default time
    if (!self.deliveryTime || [self.deliveryTime timeIntervalSinceDate:self.pickUpTime] < MINIMUM_TIME_WINDOW) {
        self.deliveryTime = [self.pickUpTime dateByAddingTimeInterval:DEFAULT_TIME_WINDOW];
    }
}

- (NSDictionary *)toQueryParameters {
    NSMutableDictionary *queryArgs = [NSMutableDictionary dictionary];
    queryArgs[@"with_status"] = @"1"; //Open shipments
    
    queryArgs[@"max_trip"] = [NSString stringWithFormat:@"%.0f", self.maximumTripDistance];
    queryArgs[@"local_search_radius"] = [NSString stringWithFormat:@"%.0f", self.searchRadius];
    
    ISO8601DateFormatter *dateFmt = [ISO8601DateFormatter new];
    [dateFmt setIncludeTime:YES];
    if (self.pickUpTime) {
        queryArgs[@"earliest_pick_up_time"] = [dateFmt stringFromDate:self.pickUpTime];
    }

    if (self.vehicleType != VehicleTypeNone) {
        queryArgs[@"show_vehicle"] = [NSNumberFromVehicleType(self.vehicleType) stringValue];
    }
    
    switch (self.orderingType) {
        case ShipmentFetchOrderingTypeByProximity:
            queryArgs[@"ordering"] = @"shipper_proximity";
            break;
        case ShipmentFetchOrderingTypeByPickUpTime:
            queryArgs[@"ordering"] = @"pick_up_time_range_end";
            break;
    }
    
    return [NSDictionary dictionaryWithDictionary:queryArgs];
}

@end
