//
//  DeliveryStatus.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 3/2/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"

@interface DeliveryStatus : TRMTLModel

@property (nonatomic) NSString *label;
@property (nonatomic) NSInteger value;

@end