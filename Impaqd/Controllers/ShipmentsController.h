//
//  ShipmentsController.h
//  Impaqd
//
//  Created by Traansmission on 4/28/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"

@class Shipment;

@interface ShipmentsController : NSObject

- (void)performFetchWithCallback:(TRControllerCallback)callback;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (Shipment *)shipmentAtIndexPath:(NSIndexPath *)indexPath;

- (void)setActiveShipments;
- (void)setCompletedShipments;

@end
