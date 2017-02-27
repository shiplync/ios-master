//
//  UpdateVersionViewController.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 7/17/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "UpdateVersionViewController.h"

@interface UpdateVersionViewController ()

@end

@implementation UpdateVersionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gotoStoreAction:(id)sender {
    NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.com/apps/traansmission"];
    [[UIApplication sharedApplication] openURL:url];
}
@end
