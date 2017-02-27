//
//  TRVehicleType.h
//  Impaqd
//
//  Created by Traansmission on 5/4/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kVehicleTypeCount 4

// Note that these enums MUST be synced ip to the server values for the truck types
typedef NS_ENUM(int16_t, VehicleType) {
    VehicleTypeNone = 0,
    VehicleTypeFlatbed = 1,
    VehicleTypeReefer = 2,
    VehicleTypeVan = 3,
    VehicleTypePowerOnly = 4
};

FOUNDATION_EXPORT NSString * NSStringFromVehicleType(VehicleType vehicleType);
FOUNDATION_EXPORT VehicleType VehicleTypeFromNSString(NSString *vehicleString);
FOUNDATION_EXPORT NSNumber * NSNumberFromVehicleType(VehicleType vehicleType);
FOUNDATION_EXPORT VehicleType VehicleTypeFromNSNumber(NSNumber *vehicleNumber);
