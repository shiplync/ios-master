//
//  WalkthroughRootViewController.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 6/24/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WalkthroughContentViewController.h"

@interface WalkthroughRootViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageContent;
@property (strong, nonatomic) NSArray *pageImageNames;
@property (weak, nonatomic) IBOutlet UILabel *existingAccountCheckLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *existingAccountCheckIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *welcomeImage;

@end
