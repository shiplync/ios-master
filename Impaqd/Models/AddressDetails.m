//
//  AddressDetails.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 2/26/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "AddressDetails.h"

@implementation AddressDetails

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"address"    : @"address",
              @"address2"   : @"address_2",
              @"city"       : @"city",
              @"state"      : @"state",
              @"zipCode"    : @"zip_code"};
}

- (NSString *)joinedAddress
{
    NSString*(^allowNil)(NSString*) = ^(NSString *value) {
        return value ? value : @"";
    };
    NSMutableArray *fields = [[NSMutableArray alloc] initWithArray:@[allowNil(self.address), allowNil(self.address2), allowNil(self.city), allowNil(self.state), allowNil(self.zipCode)]];
    [fields removeObject:@""];
    return [fields componentsJoinedByString:@", "];
}
@end