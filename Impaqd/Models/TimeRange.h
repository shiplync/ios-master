//
//  TimeRange.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 3/2/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"

@interface TimeRange : TRMTLModel

@property (nonatomic) NSDate *timeRangeStart;
@property (nonatomic) NSDate *timeRangeEnd;
@property (nonatomic) NSTimeZone *tz;
@property (nonatomic, copy, readonly) NSString *timeRangeStartDescription;
@property (nonatomic, copy, readonly) NSString *timeRangeEndDescription;
@property (nonatomic, copy, readonly) NSString *timeRangeStartDescriptionDateOnly;
@property (nonatomic, copy, readonly) NSString *timeRangeEndDescriptionDateOnly;

@end