//
//  PayoutInfo.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 3/2/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"

@interface PayoutInfo : TRMTLModel

@property (nonatomic, readonly) NSNumber *payout;
@property (nonatomic, readonly) NSNumber *payoutDistance;
- (NSString*)formattedPayout;
- (NSNumber*)convertedPayoutDistance;
- (NSString*)formattedPayoutDistance;

@end