//
//  RootViewController.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 10/7/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Shipment;

@interface RootViewController : UITabBarController

- (void)presentShipmentDetails:(Shipment *)shipment;
- (void)presentActiveShipments;

@end
