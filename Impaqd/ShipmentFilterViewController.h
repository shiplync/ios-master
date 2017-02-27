//
//  ShipmentFilterViewController.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/19/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterFormView.h"
#import "ShipmentFilterViewControllerDelegate.h"

@interface ShipmentFilterViewController : UIViewController

@property (weak, nonatomic) IBOutlet FilterFormView *filterForm;
@property (weak, nonatomic) id<ShipmentFilterViewControllerDelegate> delegate;

- (IBAction)searchTapped:(id)sender;

@end