//
//  DeliveredShipmentCell.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/18/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Shipment;

@interface DeliveredShipmentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *shipmentIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *payoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveredAtLabel;

@property (nonatomic, weak) Shipment *shipment;

@end
