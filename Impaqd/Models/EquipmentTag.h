//
//  EquipmentTag.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 3/2/16.
//  Copyright (c) 2016 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"

@interface EquipmentTag : TRMTLModel

@property (nonatomic) NSString *tagTypeLabel;
@property (nonatomic) NSInteger tagType;
@property (nonatomic) NSString *tagCategoryLabel;
@property (nonatomic) NSInteger tagCategory;

@end