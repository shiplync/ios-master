//
//  PreVerifiedViewController.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 7/2/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "PreVerifiedViewController.h"
#import <Mixpanel/Mixpanel.h>
#import "APISessionManager.h"
#import "AccountController.h"

@interface PreVerifiedViewController ()

@property (nonatomic) AccountController *accountController;

@end

@implementation PreVerifiedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.accountController = [AccountController sharedInstance];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self refreshAction:self];
    self.view.hidden = false;
    
    //ANALYTICS START
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"entered not verified"];
    //ANALYTICS END
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)refreshAction:(id)sender {
    [self.accountController statusWithParameters:nil completion:[self carriersStatusCompletion]];
}

#pragma mark - Private Instance Methods

- (TRControllerCallback)carriersStatusCompletion {
    return ^(NSError *error) {
        if (error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                UIAlertController *alert = [UIAlertController alertControllerWithError:error];
                [self presentViewController:alert animated:YES completion:nil];
            }];
            return;
        }
        if ([[self.accountController account] isVerified]) {
            [self performSegueWithIdentifier:@"carrierVerified" sender:nil];
        }
    };
}

@end
