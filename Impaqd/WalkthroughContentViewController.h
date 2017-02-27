//
//  WalkthroughContentViewController.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 6/24/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WalkthroughContentViewController : UIViewController
@property NSUInteger pageIndex;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentText;
@property (weak, nonatomic) IBOutlet UIImageView *contentImage;
@property NSString *titleTextHolder;
@property NSString *contentTextHolder;
@property NSString *imageNameHolder;
@property BOOL lastScreen;
- (IBAction)registerAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end
