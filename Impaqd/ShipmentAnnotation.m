//
//  ShipmentAnnotation.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/11/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "ShipmentAnnotation.h"
#import "Shipment.h"
#import "HelperFunctions.h"

@implementation ShipmentAnnotation

- (id)initWithShipment:(Shipment *)shipment
{
    self = [super init];
    if (self) {
        _shipment = shipment;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate {
    return self.shipment.pickUpCoordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    // NO-OP
}

- (NSString *)title
{
    //Use value from server
    NSDecimalNumber *distMiles = self.shipment.tripDistanceMiles;
    NSString *fmtString = distMiles.doubleValue > 10.0 ? @"Trip: %.0f miles" : @"Trip: %.1f miles";
    return [NSString stringWithFormat:fmtString, distMiles.floatValue];
}

- (NSString *)subtitle
{
    [[HelperFunctions sharedInstance] convertDateIfNecessary:self.shipment];
    return [[HelperFunctions sharedInstance] getDateString:self.shipment.pickUpTimeRangeEnd withTimeZone:self.shipment.pickupTz];
}

@end
