//
//  TRDateRange.h
//  Impaqd
//
//  Created by Traansmission on 6/15/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRDateRange : NSObject

@property (nonatomic, readonly) NSDate *startDate;
@property (nonatomic, readonly) NSDate *endDate;

- (instancetype)initWithStart:(NSDate *)start end:(NSDate *)end;

@end
