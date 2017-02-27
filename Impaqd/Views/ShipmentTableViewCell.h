//
//  ShipmentTableViewCell.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 3/3/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shipment.h"

@interface ShipmentTableViewCell : UITableViewCell

@property (nonatomic) Shipment *shipment;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromLocation;
@property (weak, nonatomic) IBOutlet UILabel *toLocation;
@property (weak, nonatomic) IBOutlet UILabel *fromTime;
@property (weak, nonatomic) IBOutlet UILabel *toTime;

@end
