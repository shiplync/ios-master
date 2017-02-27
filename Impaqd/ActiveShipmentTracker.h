//
//  ActiveShipmentTracker.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/20/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ShipmentTrackingDelegate.h"
#import "ShipmentRegionEventDelegate.h"
#import "ActiveShipmentTrackerDelegate.h"
#import "GotoMyShipmentsDelegate.h"
#import "RefreshMyShipmentsDelegate.h"

@class Shipment;
@class LocationCoordinator;

@interface ActiveShipmentTracker : NSObject <ShipmentTrackingDelegate, ShipmentRegionEventDelegate>

@property (nonatomic, strong) Shipment *shipment;
@property (nonatomic, weak) LocationCoordinator *locationCoordinator;
@property (nonatomic, weak) id<GotoMyShipmentsDelegate> gotoMyShipmentsDelegate;
@property (nonatomic, weak) id<RefreshMyShipmentsDelegate> refreshMyShipmentsDelegate;

@property (nonatomic, weak) id<ActiveShipmentTrackerDelegate> delegate;

+ (instancetype)sharedInstance;
- (void)cancelActiveShipmentWithBlock:(void (^)(NSError*, id))block;
- (void) gotoMyShipmentsView;
- (void)claimShipmentWithBlock:(void (^)(NSError*, id))block withShipment:(Shipment*)shipment;

@end
