//
//  ShipmentFeatures.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 3/1/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"

@interface ShipmentFeatures : TRMTLModel

@property (nonatomic, readonly) NSNumber *weight;
@property (nonatomic, readonly) NSNumber *palletized;
@property (nonatomic, readonly) NSNumber *palletHeight;
@property (nonatomic, readonly) NSNumber *palletLength;
@property (nonatomic, readonly) NSNumber *palletWidth;
@property (nonatomic, readonly) NSNumber *palletNumber;

@property (nonatomic, copy, readonly) NSString *palletDimensions;
- (BOOL)isPalletized;

@end