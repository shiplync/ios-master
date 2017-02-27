//
//  Company.h
//  Impaqd
//
//  Created by Traansmission on 5/6/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"

@interface Company : TRMTLModel

@property (nonatomic) NSNumber *traansmissionId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSNumber *DOT;
@property (nonatomic) NSNumber *MC;
@property (nonatomic) NSString *insurance;

@property (nonatomic, getter=isFleet) BOOL fleet;
@property (nonatomic) NSNumber *maximumRequests;

@property (nonatomic, readonly, getter=isRejected) BOOL rejected;
@property (nonatomic, getter=isVerified) BOOL verified;

@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *updatedAt;

@end


