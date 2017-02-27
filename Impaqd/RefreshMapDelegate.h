//
//  RefreshMapDelegate.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 10/14/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocationCoordinator;

DEPRECATED_ATTRIBUTE
@protocol RefreshMapDelegate <NSObject>

- (void)refreshMapOnLocationAuthorization;

@end