//
//  ActiveShipmentTrackerDelegate.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/20/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Shipment;

DEPRECATED_ATTRIBUTE
@protocol ActiveShipmentTrackerDelegate <NSObject>

- (void)activeShipmentDidChange:(Shipment *)newShipment;
- (void)activeShipmentPickUpOccurred:(Shipment *)shipment;
- (void)activeShipmentDeliveryOccurred:(Shipment *)shipment;

@end
