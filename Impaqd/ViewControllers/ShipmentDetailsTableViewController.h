//
//  ShipmentDetailsTableViewController.h
//  Impaqd
//
//  Created by Traansmission on 6/12/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Shipment;

@interface ShipmentDetailsTableViewController : UITableViewController

@property (nonatomic) Class controllerClass;
@property (nonatomic) Shipment *shipment;

@end
