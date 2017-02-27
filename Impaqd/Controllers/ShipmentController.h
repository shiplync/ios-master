//
//  ShipmentController.h
//  Impaqd
//
//  Created by Traansmission on 6/15/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Shipment;

@interface ShipmentController : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) Shipment *shipment;
- (instancetype)initWithShipment:(Shipment *)shipment;

- (NSString *)reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)titleForCellAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)detailForCellAtIndexPath:(NSIndexPath *)indexPath;

@end
