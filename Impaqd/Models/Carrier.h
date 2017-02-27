//
//  Carrier.h
//  Impaqd
//
//  Created by Traansmission on 5/14/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"
#import "Company.h"
#import "ProfilePhoto.h"
#import "AccountProtocol.h"

@interface Carrier : TRMTLModel <AccountProtocol>

@property (nonatomic, copy) NSNumber *traansmissionId;
@property (nonatomic, copy) NSNumber *userId;

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NBPhoneNumber *phoneNumber;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;

@property (nonatomic) enum VehicleType vehicleType;

@property (nonatomic, copy) Company *company;
@property (nonatomic, copy) ProfilePhoto *profilePhoto;

@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *updatedAt;

@end
