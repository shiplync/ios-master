//
//  ActiveShipmentCell.h
//  Impaqd
//
//  Created by Traansmission on 4/28/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ENUM(NSInteger, ShipmentCellStyle) {
    ShipmentCellStyleUnknown,
    ShipmentCellStyleActive,
    ShipmentCellStyleAvailable,
    ShipmentCellStyleComplete,
};

@class Shipment;

@interface ShipmentCell : UITableViewCell

@property (nonatomic) enum ShipmentCellStyle style;
@property (nonatomic) Shipment *shipment;

@end
