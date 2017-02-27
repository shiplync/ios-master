//
//  TRMTLModel.h
//  Impaqd
//
//  Created by Traansmission on 6/11/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TRMTLModel : MTLModel <MTLJSONSerializing>

+ (NSValueTransformer *)NSDateJSONTransformer;
+ (NSValueTransformer *)NSNumberToBOOLJSONTransformer;
+ (NSValueTransformer *)NSTimeZoneJSONTransformer;
+ (NSValueTransformer *)NSURLJSONTransformer;
+ (NSValueTransformer *)NSUUIDJSONTransformer;
+ (NSValueTransformer *)PhoneNumberJSONTransformer;

+ (NSDateFormatter *)dateFormatter;
+ (NSDateFormatter *)dateFormatterWithMilliseconds;

@end
