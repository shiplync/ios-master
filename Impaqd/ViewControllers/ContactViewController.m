//
//  ContactViewController.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/21/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "ContactViewController.h"
#include "ATConnect.h"

@interface ContactViewController ()

@end

@implementation ContactViewController

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
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)emailTapped:(id)sender {
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:admin@traansmission.com"]];
    [[ATConnect sharedConnection] presentMessageCenterFromViewController:self];
}

- (IBAction)callTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:1-412-447-5623"]];
}

@end
