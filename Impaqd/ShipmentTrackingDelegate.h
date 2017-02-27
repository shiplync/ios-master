//
//  ShipmentTrackingDelegate.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/20/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocationCoordinator;
@class CLLocation;

DEPRECATED_ATTRIBUTE
@protocol ShipmentTrackingDelegate <NSObject>

- (void)locationCoordinator:(LocationCoordinator *)coordinator didReceiveTrackingUpdateWithLocation:(CLLocation *)location;

@end
