//
//  ShipmentAnnotation.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/11/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Shipment;

@interface ShipmentAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) Shipment *shipment;

- (id)initWithShipment:(Shipment *)shipment;

- (CLLocationCoordinate2D)coordinate;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

- (NSString *)title;
- (NSString *)subtitle;

@end
