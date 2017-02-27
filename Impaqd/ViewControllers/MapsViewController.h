//
//  MapsViewController.h
//  Impaqd
//
//  Created by Traansmission on 6/3/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"
#import <MapKit/MapKit.h>

@class PermissionsController;
@class OpenShipmentsController;

@interface MapsViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) PermissionsController *permissionsController;
@property (weak, nonatomic) OpenShipmentsController *shipmentsController;

- (IBAction)centerOnUserLocation:(id)sender;
- (void)reloadData;

@end
