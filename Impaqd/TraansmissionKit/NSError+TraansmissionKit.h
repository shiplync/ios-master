//
//  NSError+TraansmissionKit.h
//  Impaqd
//
//  Created by Traansmission on 4/9/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const TRErrorDomain;

NS_ENUM(NSInteger, TRErrorCode) {
    TRErrorUserNotificationsDenied   = 999930,
    TRErrorRemoteNotificationsDenied = 999940,
    TRErrorLocationServicesDenied    = 999950,
    TRErrorLocationServicesLimited   = 999960,
    
    TRErrorRegistration       = 999970,
    TRErrorInvalidAccountType = 999980,
    TRErrorVersionCheckFailed = 999990,
};

@interface NSError (TraansmissionKit)

+ (instancetype)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo;
+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)description;
+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason;
+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason recovery:(NSString *)recovery;
+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason recovery:(NSString *)recovery options:(NSArray *)options;
+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason recovery:(NSString *)recovery options:(NSArray *)options attempter:(NSObject *)attempter;

+ (instancetype)URLCannotConnectToHostWithAttempter:(NSObject *)attempter;
+ (instancetype)serverError;

@property (nonatomic, copy, readonly) NSString *localizedAlertTitle;
@property (nonatomic, copy, readonly) NSString *localizedAlertMessage;

@end
