//
//  FilterFormView.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/19/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AvailableShipmentSearchParameters;

@interface FilterFormView : UITableView <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

@property (nonatomic, weak) AvailableShipmentSearchParameters *searchParams;

@end
