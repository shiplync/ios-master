//
//  ShipmentFilterViewController.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/19/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "ShipmentFilterViewController.h"
#import "LocationCoordinator.h"

@interface ShipmentFilterViewController ()

@end

@implementation ShipmentFilterViewController

- (IBAction)searchTapped:(id)sender {
    [self.delegate formCompleted:self];
}

@end
