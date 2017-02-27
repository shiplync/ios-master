//
//  EquipmentTag.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 3/2/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "EquipmentTag.h"

@implementation EquipmentTag

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{ @"tagCategory"           : @"tag_category",
              @"tagCategoryLabel"      : @"tag_category_label",
              @"tagType"               : @"tag_type",
              @"tagTypeLabel"          : @"tag_type_label"};

}

- (NSString *)description
{
    return self.tagTypeLabel;
}

@end