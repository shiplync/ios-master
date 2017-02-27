//
//  AvailableShipmentSearchOptions.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/24/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Shipment.h"

typedef NS_ENUM(NSInteger, ShipmentFetchOrderingType) {
    //ShipmentFetchOrderingTypeByPayout,
    ShipmentFetchOrderingTypeByProximity,
    ShipmentFetchOrderingTypeByPickUpTime
};

@interface AvailableShipmentSearchParameters : NSObject

@property (nonatomic, assign) VehicleType vehicleType;
@property (nonatomic, assign) CLLocationDistance maximumTripDistance;
@property (nonatomic, strong) NSDecimalNumber *minimumPayoutUSD;

@property (nonatomic, assign) ShipmentFetchOrderingType orderingType;

@property (nonatomic, assign) CLLocationDistance searchRadius;
@property (nonatomic, copy) NSDate *pickUpTime;
@property (nonatomic, copy) NSDate *deliveryTime;

+ (instancetype)sharedInstance;

- (void)updateTimeParameters;

- (NSDictionary *)toQueryParameters;

@end
