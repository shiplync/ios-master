//
//  DetailViewController.h
//  Traansmission-sandbox
//
//  Created by Lars Emil Lamm Nielsen on 3/24/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

