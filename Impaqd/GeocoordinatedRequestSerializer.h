//
//  GeocoordinatedRequestSerializer.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/20/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "AFURLRequestSerialization.h"
@class LocationCoordinator;

@interface GeocoordinatedRequestSerializer : AFHTTPRequestSerializer

- (instancetype)initWithLocationCoordinator:(LocationCoordinator *)coordinator;

@property (nonatomic, weak) LocationCoordinator *locationCoordinator;

@end
