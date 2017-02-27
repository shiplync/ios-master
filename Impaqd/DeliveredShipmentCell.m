//
//  DeliveredShipmentCell.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/18/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "DeliveredShipmentCell.h"
#import "Shipment.h"

@implementation DeliveredShipmentCell

- (void)setShipment:(Shipment *)shipment
{
    _shipment = shipment;
    
    self.shipmentIdLabel.text = shipment.shipmentId;
    
    //    self.payoutLabel.text = [NSNumberFormatter localizedStringFromNumber:shipment.payoutUSD
    //                                                             numberStyle:NSNumberFormatterCurrencyStyle];
    if(shipment.payoutUSD.doubleValue > 0.0 && shipment.payoutUSD.doubleValue < 999999.0){
        self.payoutLabel.text = [NSNumberFormatter localizedStringFromNumber:shipment.payoutUSD
                                                                           numberStyle:NSNumberFormatterCurrencyStyle];
    }else{
        self.payoutLabel.text = @"N/A";
    }
    
    self.deliveredAtLabel.text = [NSDateFormatter localizedStringFromDate:shipment.deliveredAt
                                                               dateStyle:NSDateFormatterShortStyle
                                                               timeStyle:NSDateFormatterShortStyle];
}

@end
