//
//  OpenShipmentsTableViewController.h
//  Impaqd
//
//  Created by Traansmission on 6/3/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+EmptyDataSet.h"

@class OpenShipmentsController;

@interface OpenShipmentsTableViewController : UITableViewController <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

//@property (weak, nonatomic) OpenShipmentsController *shipmentsController;
- (void)reloadData;
- (IBAction)refreshButtonAction:(id)sender;

@end
