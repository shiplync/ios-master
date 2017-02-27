//
//  ShipmentRegionEventDelegate.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/20/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LocationCoordinator;

DEPRECATED_ATTRIBUTE
@protocol ShipmentRegionEventDelegate <NSObject>

- (void)didObservePickUpWithLocationCoordinator:(LocationCoordinator *)coordinator;
- (void)didObserveDeliveryWithLocationCoordinator:(LocationCoordinator *)coordinator;

@end
