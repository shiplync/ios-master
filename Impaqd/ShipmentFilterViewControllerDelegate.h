//
//  ShipmentFilterViewControllerDelegate.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/19/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShipmentFilterViewController;

DEPRECATED_ATTRIBUTE
@protocol ShipmentFilterViewControllerDelegate <NSObject>

- (void)formCompleted:(ShipmentFilterViewController *)formView;

@end
