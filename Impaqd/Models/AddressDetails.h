//
//  AddressDetails.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 2/26/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"

@interface AddressDetails : TRMTLModel

@property (nonatomic) NSString *address;
@property (nonatomic) NSString *address2;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *state;
@property (nonatomic) NSString *zipCode;

- (NSString *)joinedAddress;

@end