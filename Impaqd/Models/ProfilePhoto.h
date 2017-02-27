//
//  ProfilePhoto.h
//  Impaqd
//
//  Created by Traansmission on 5/6/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"

@interface ProfilePhoto : TRMTLModel

@property (nonatomic, readonly) NSNumber *traansmissionId;
@property (nonatomic, readonly) NSURL    *URL;
@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSUUID   *UUID;
@property (nonatomic, readonly) NSDate   *createdAt;
@property (nonatomic, readonly) NSDate   *updatedAt;

@end
