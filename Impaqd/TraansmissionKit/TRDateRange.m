//
//  TRDateRange.m
//  Impaqd
//
//  Created by Traansmission on 6/15/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRDateRange.h"

@interface TRDateRange ()

@property (nonatomic, readwrite) NSDate *startDate;
@property (nonatomic, readwrite) NSDate *endDate;

@end

@implementation TRDateRange

- (instancetype)initWithStart:(NSDate *)start end:(NSDate *)end {
    self = [super init];
    if (self) {
        self.startDate = start;
        self.endDate = end;
    }
    return self;
}

@end
