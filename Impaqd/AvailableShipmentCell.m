//
//  AvailableShipmentCell.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/8/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "AvailableShipmentCell.h"
#import "Shipment.h"
#import "LocationCoordinator.h"
#import <MapKit/MapKit.h>
#import "HelperFunctions.h"

@implementation AvailableShipmentCell

- (void)setShipment:(Shipment *)shipment
{
//    _shipment = shipment;
//
//    if(shipment.payoutUSD.doubleValue > 0.0 && shipment.payoutUSD.doubleValue < 999999.0){
//        self.payoutLabel.text = [NSNumberFormatter localizedStringFromNumber:shipment.payoutUSD
//                                                                           numberStyle:NSNumberFormatterCurrencyStyle];
//    }else{
//        self.payoutLabel.text = shipment.payoutUSDtext;
//    }
//    [[HelperFunctions sharedInstance] convertDateIfNecessary:shipment];
//    self.pickupTimeLabel.text = [[HelperFunctions sharedInstance] getDateString:shipment.pickUpTimeRangeStart withTimeZone:shipment.pickupTz];
//
//    CLLocation *currentLocation = [[LocationCoordinator sharedInstance] lastLocation];
//    if (currentLocation) {
//        CLLocation *pickUpLocation = [[CLLocation alloc] initWithLatitude:shipment.pickUpCoordinate.latitude longitude:shipment.pickUpCoordinate.longitude];
//        CLLocationDistance distance = [currentLocation distanceFromLocation:pickUpLocation];
//        MKDistanceFormatter *formatter = [[MKDistanceFormatter alloc] init];
//        formatter.units = MKDistanceFormatterUnitsImperial;
//        self.distanceLabel.text = [NSString stringWithFormat:@"%@ away", [formatter stringFromDistance:distance]];
//    }
//    else {
//        self.distanceLabel.text = @"--";
//    }
    
}

@end
