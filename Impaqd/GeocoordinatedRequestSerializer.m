//
//  GeocoordinatedRequestSerializer.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/20/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "GeocoordinatedRequestSerializer.h"
#import "LocationCoordinator.h"
#import <CoreLocation/CoreLocation.h>

static NSString * coordinateToGeoURI(CLLocationCoordinate2D coordinate) {
    return [NSString stringWithFormat:@"geo:%.6f,%.6f", coordinate.longitude, coordinate.latitude];
}

@implementation GeocoordinatedRequestSerializer

- (instancetype)initWithLocationCoordinator:(LocationCoordinator *)coordinator
{
    self = [super init];
    if (self) {
        _locationCoordinator = coordinator;
    }
    return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error
{
    CLLocation *location = [_locationCoordinator lastLocation];
    if (location) {
        NSString *geoURI = coordinateToGeoURI(location.coordinate);
        [self setValue:geoURI forHTTPHeaderField:@"Geolocation"];
    }
    return [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
}

@end
