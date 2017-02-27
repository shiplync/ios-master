//
//  RefreshMyShipmentsDelegate.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 2/6/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ActiveShipmentTracker;

DEPRECATED_ATTRIBUTE
@protocol RefreshMyShipmentsDelegate <NSObject>

- (void)refreshMyShipmentsView;

@end