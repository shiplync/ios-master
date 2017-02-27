//
//  AvailableShipmentCell.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/8/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Shipment;

@interface AvailableShipmentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *payoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickupTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (nonatomic, weak) Shipment *shipment;

@end
