//
//  Person.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 2/29/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"

@interface Person : TRMTLModel

@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *phone;
@property (nonatomic) NSString *email;

@end