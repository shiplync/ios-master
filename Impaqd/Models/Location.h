//
//  Location.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 2/26/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"
#import "AddressDetails.h"
#import "Person.h"
#import "LocationType.h"
#import "ShipmentFeatures.h"
#import "TimeRange.h"

@interface Location : TRMTLModel

@property (nonatomic) LocationType *locationType;
@property (nonatomic) NSString *companyName;
@property (nonatomic) AddressDetails *addressDetails;
@property (nonatomic, copy) NSNumber *traansmissionId;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *updatedAt;
@property (nonatomic, readonly) Person *contact;
@property (nonatomic, readonly) ShipmentFeatures *features;
@property (nonatomic, readonly) TimeRange *timeRange;
@property (nonatomic) NSDate *arrivalTime;
@property (nonatomic, copy, readonly) NSString *arrivalTimeDescription;


@end