//
//  NSError+TraansmissionKit.m
//  Impaqd
//
//  Created by Traansmission on 4/9/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "NSError+TraansmissionKit.h"

NSString *const TRErrorDomain = @"com.traansmission.ios.errors";

@implementation NSError (TraansmissionKit)

#pragma mark - Class Methods

+ (instancetype)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    NSParameterAssert(code);
    return [self errorWithDomain:TRErrorDomain code:code userInfo:userInfo];
}

+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)description {
    NSParameterAssert(code);
    NSParameterAssert(description);
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : description };
    return [self errorWithCode:code userInfo:userInfo];
}

+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason {
    NSParameterAssert(code);
    NSParameterAssert(description);
    NSParameterAssert(reason);
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : description,
                                NSLocalizedFailureReasonErrorKey : reason };
    return [self errorWithCode:code userInfo:userInfo];
}

+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason recovery:(NSString *)recovery {
    NSParameterAssert(code);
    NSParameterAssert(description);
    NSParameterAssert(reason);
    NSParameterAssert(recovery);
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : description,
                                NSLocalizedFailureReasonErrorKey : reason,
                                NSLocalizedRecoverySuggestionErrorKey : recovery };
    return [self errorWithCode:code userInfo:userInfo];
}

+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason recovery:(NSString *)recovery options:(NSArray *)options {
    NSParameterAssert(code);
    NSParameterAssert(description);
    NSParameterAssert(reason);
    NSParameterAssert(recovery);
    NSParameterAssert(options);
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : description,
                                NSLocalizedFailureReasonErrorKey : reason,
                                NSLocalizedRecoverySuggestionErrorKey : recovery,
                                NSLocalizedRecoveryOptionsErrorKey : options };
    return [self errorWithCode:code userInfo:userInfo];
}

+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason recovery:(NSString *)recovery options:(NSArray *)options attempter:(NSObject *)attempter {
    NSParameterAssert(code);
    NSParameterAssert(description);
    NSParameterAssert(reason);
    NSParameterAssert(recovery);
    NSParameterAssert(options);
    NSParameterAssert(attempter);
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : description,
                                NSLocalizedFailureReasonErrorKey : reason,
                                NSLocalizedRecoverySuggestionErrorKey : recovery,
                                NSLocalizedRecoveryOptionsErrorKey : options,
                                NSRecoveryAttempterErrorKey : attempter };
    return [self errorWithCode:code userInfo:userInfo];
}

+ (instancetype)URLCannotConnectToHostWithAttempter:(NSObject *)attempter {
    NSArray *options = (attempter ? @[ @"Try Again", @"OK" ] : @[ @"OK" ]);
    NSError *error;
    if (attempter) {
        error = [NSError errorWithCode:NSURLErrorCannotConnectToHost
                                    description:@"Problem Contacting Server"
                                        reason:@"We can't contact the Traansmission Server."
                                    recovery:@"Try again now or come back when you have a working internet connection"
                                        options:options
                                    attempter:attempter];
    }
    else {
        error = [NSError errorWithCode:NSURLErrorCannotConnectToHost
                           description:@"Problem Contacting Server"
                                reason:@"We can't contact the Traansmission Server."
                              recovery:@"Try again now or come back when you have a working internet connection"
                               options:options];
    }
    return error;
}

+ (instancetype)serverError {
    return [NSError errorWithCode:NSURLErrorBadServerResponse
                      description:@"Problem on the Server"
                           reason:@"Sorry, there's a problem on the Traansmission Server"
                         recovery:@"Try again, or contact us if you continue to have problems"
                          options:@[ @"OK" ]];
}

#pragma mark - Instance Methods

- (NSString *)localizedAlertTitle {
    return [self localizedDescription];
}

- (NSString *)localizedAlertMessage {
    NSString *message = [self localizedFailureReason];
    if ([self localizedRecoverySuggestion]) {
        message = [message stringByAppendingFormat:@"\n%@", [self localizedRecoverySuggestion]];
    }
    return message;
}

@end
