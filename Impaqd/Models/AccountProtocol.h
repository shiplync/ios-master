//
//  AccountProtocol.h
//  Impaqd
//
//  Created by Traansmission on 5/15/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"
#import "ProfilePhoto.h"
#import <libPhoneNumber-iOS/NBPhoneNumber.h>

@protocol AccountProtocol <NSObject, NSCoding, NSCopying>

@required
@property (nonatomic, copy)   NSNumber        *traansmissionId;
@property (nonatomic, copy)   NSString        *email;
@property (nonatomic, copy)   NBPhoneNumber   *phoneNumber;
@property (nonatomic, copy)   NSString        *firstName;
@property (nonatomic, copy)   NSString        *lastName;

@property (nonatomic, assign, getter=isVerified) BOOL verified;

@property (nonatomic, copy)   NSString        *companyName;
@property (nonatomic, copy)   NSNumber        *dotNumber;
@property (nonatomic, copy)   ProfilePhoto    *profilePhoto;
@property (nonatomic, assign) enum VehicleType vehicleType;

@property (nonatomic, copy, readonly) NSURL    *profileImageURL;
@property (nonatomic, copy, readonly) NSString *phoneNumberE164;
@property (nonatomic, copy, readonly) NSString *phoneNumberNational;

- (NSDictionary *)registrationParameters;
- (NSDictionary *)patchParameters;

@property (nonatomic, copy) UIImage *photo DEPRECATED_ATTRIBUTE;

@end
