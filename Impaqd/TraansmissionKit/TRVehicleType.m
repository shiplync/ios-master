//
//  TRVehicleType.m
//  Impaqd
//
//  Created by Traansmission on 5/4/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRVehicleType.h"

FOUNDATION_EXPORT NSString * NSStringFromVehicleType(VehicleType vehicleType) {
    NSString *vehicleString;
    switch (vehicleType) {
        case VehicleTypeNone:
            vehicleString = @"None";
            break;
            
        case VehicleTypeFlatbed:
            vehicleString = @"Flatbed";
            break;

        case VehicleTypeReefer:
            vehicleString = @"Reefer";
            break;
            
        case VehicleTypeVan:
            vehicleString = @"Van";
            break;
            
        case VehicleTypePowerOnly:
            vehicleString = @"Power Only";
            break;
            
        default:
            @throw [NSException exceptionWithName:@"Unknown Vehicle Type"
                                           reason:[NSString stringWithFormat:@"%hd is unknown VehicleType Enum", vehicleType]
                                         userInfo:nil];
            break;
            
    }
    return vehicleString;
}

FOUNDATION_EXPORT VehicleType VehicleTypeFromNSString(NSString *vehicleString) {
    if ([vehicleString isEqualToString:@"None"]) {
        return VehicleTypeNone;
    }
    else if ([vehicleString isEqualToString:@"Flatbed"]) {
        return VehicleTypeFlatbed;
    }
    else if ([vehicleString isEqualToString:@"Reefer"]) {
        return VehicleTypeReefer;
    }
    else if ([vehicleString isEqualToString:@"Van"]) {
        return VehicleTypeVan;
    }
    else if ([vehicleString isEqualToString:@"Power Only"]) {
        return VehicleTypePowerOnly;
    }
    else {
        @throw [NSException exceptionWithName:@"Unknown Vehicle Type String"
                                       reason:[NSString stringWithFormat:@"%@ is unknown VehicleType", vehicleString]
                                     userInfo:nil];
    }
}

FOUNDATION_EXPORT NSNumber * NSNumberFromVehicleType(VehicleType vehicleType) {
    NSNumber *vehicleNumber;
    switch (vehicleType) {
        case VehicleTypeNone:
        case VehicleTypeFlatbed:
        case VehicleTypeReefer:
        case VehicleTypeVan:
        case VehicleTypePowerOnly:
            vehicleNumber = @(vehicleType);
            break;
            
        default:
            @throw [NSException exceptionWithName:@"Unknown Vehicle Type"
                                           reason:[NSString stringWithFormat:@"%hd is unknown VehicleType Enum", vehicleType]
                                         userInfo:nil];
            break;
            
    }
    return vehicleNumber;
}

FOUNDATION_EXPORT VehicleType VehicleTypeFromNSNumber(NSNumber *vehicleNumber) {
    NSInteger vehicleInteger = [vehicleNumber integerValue];
    switch (vehicleInteger) {
        case VehicleTypeNone:
            return VehicleTypeNone;
            break;

        case VehicleTypeFlatbed:
            return VehicleTypeFlatbed;
            break;

        case VehicleTypeReefer:
            return VehicleTypeReefer;
            break;

        case VehicleTypeVan:
            return VehicleTypeVan;
            break;

        case VehicleTypePowerOnly:
            return VehicleTypePowerOnly;
            break;
            
        default:
            @throw [NSException exceptionWithName:@"Unknown Vehicle Type"
                                           reason:[NSString stringWithFormat:@"%ld is unknown VehicleType Enum", (long)vehicleInteger]
                                         userInfo:nil];
            break;
            
    }
}

