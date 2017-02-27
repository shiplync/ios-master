//
//  APIOperationManager.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/23/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface APIOperationManager : AFHTTPRequestOperationManager

+ (instancetype)sharedInstance;
- (void)setToken:(NSString*)token;
- (void)clearToken;

@end
