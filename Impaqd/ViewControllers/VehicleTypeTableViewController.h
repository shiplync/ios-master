//
//  VehicleTypeTableViewController.h
//  Impaqd
//
//  Created by Traansmission on 5/4/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TraansmissionKit.h"

@protocol VehicleTypeChooserProtocol <NSObject>

@property (nonatomic) VehicleType selectedVehicleType;
- (IBAction)unwindFromVehicleTypeTableViewController:(UIStoryboardSegue *)segue;

@end

@interface VehicleTypeTableViewController : UITableViewController

@property (nonatomic) VehicleType selectedVehicleType;

@end
