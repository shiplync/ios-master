//
//  ProfilePhoto.m
//  Impaqd
//
//  Created by Traansmission on 5/6/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "ProfilePhoto.h"

@implementation ProfilePhoto

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    return dateFormatter;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"traansmissionId" : @"id",
              @"URL"             : @"file_url",
              @"path"            : @"path",
              @"UUID"            : @"uuid_value",
              @"createdAt"       : @"created_at",
              @"updatedAt"       : @"updated_at" };
}

+ (NSValueTransformer *)URLJSONTransformer {
    return [self NSURLJSONTransformer];
}

+ (NSValueTransformer *)UUIDJSONTransformer {
    return [self NSUUIDJSONTransformer];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [self NSDateJSONTransformer];
}

+ (NSValueTransformer *)updatedAtJSONTransformer {
    return [self NSDateJSONTransformer];
}

@end
