//
//  TRJSONResponseSerializer.m
//  Impaqd
//
//  Created by Traansmission on 4/3/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TRJSONResponseSerializer.h"

NSString * const TRJSONResponseSerializerKey = @"TRJSONResponseSerializerKey";

@implementation TRJSONResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    id JSONResponseObject = [super responseObjectForResponse:response data:data error:error];
    if (*error) {
        NSMutableDictionary *userInfo = [[*error userInfo] mutableCopy];
        if (data) {
            id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (jsonData) {
                userInfo[TRJSONResponseSerializerKey] = jsonData;
            }
        }
        *error = [NSError errorWithDomain:[*error domain] code:[*error code] userInfo:userInfo];
    }
    return JSONResponseObject;
}
@end
