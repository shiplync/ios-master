//
//  ShipmentTableViewCell.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 3/3/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "ShipmentTableViewCell.h"

@implementation ShipmentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setShipment:(Shipment *)shipment {
    _shipment = shipment;
    //    [self setTextLabels];
    //    [self setDetailLabels];
    [self setLabels];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setLabels
{
    [self.idLabel setText:[NSString stringWithFormat:@"#%@", self.shipment.shipmentId]];
    [self.statusLabel setText:self.shipment.deliveryStatus.label];
    [self.fromLocation setText:[NSString stringWithFormat:@"%@, %@", ((Location*)self.shipment.locations.firstObject).addressDetails.city, ((Location*)self.shipment.locations.firstObject).addressDetails.state]];
    [self.fromTime setText:((Location*)self.shipment.locations.firstObject).timeRange.timeRangeEndDescriptionDateOnly];
    [self.toLocation setText:[NSString stringWithFormat:@"%@, %@", ((Location*)self.shipment.locations.lastObject).addressDetails.city, ((Location*)self.shipment.locations.lastObject).addressDetails.state]];
    [self.toTime setText:((Location*)self.shipment.locations.lastObject).timeRange.timeRangeEndDescriptionDateOnly];
}

@end
