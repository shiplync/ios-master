//
//  SetPasswordViewController.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 10/29/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "SetPasswordViewController.h"
#import "APIOperationManager.h"
#import "Account.h"
#import "sharedConstants.h"
#import <SSKeychain/SSKeychain.h>
#import "AccountController.h"

@interface SetPasswordViewController ()

@end

@implementation SetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.passwordTextField.delegate = self;
    self.passwordConfirmTextField.delegate = self;
    
    [self.passwordTextField addTarget:self
                               action:@selector(textFieldChanged)
                     forControlEvents:UIControlEventEditingChanged];
    
    [self.passwordConfirmTextField addTarget:self
                               action:@selector(textFieldChanged)
                     forControlEvents:UIControlEventEditingChanged];
    
    [self updateSubmitButtonEnabledStatus];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.passwordTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)setPasswordAction:(id)sender {
    NSString *password = self.passwordTextField.text;
    NSString *serverID = [[[[AccountController sharedInstance] activeUserAccount] traansmissionId] stringValue];
    NSString *urlString = @"register_existing_carrier/";
    NSDictionary *params = @{
                             @"carrier_id": serverID,
                             @"password": password
                             };
    APIOperationManager *mgr = [APIOperationManager sharedInstance];
    [mgr POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = responseObject;
        NSString *token = [response objectForKey:@"token"];
        if (token) {
            [[AccountController sharedInstance] setAccountToken:token];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *mainVC = [storyBoard instantiateViewControllerWithIdentifier:@"mainStartVC"];
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            [window setRootViewController:mainVC];
        }else{
            //this should never happen
            NSLog(@"Wrong response! %@", response);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([operation.response statusCode] == 409){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seems you already are registered"
                                                            message:@"We apoligize asking for your password again. Please login with your existing credentials"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            alert.tag = 1;
            [alert show];
            NSLog(@"Network error  %@", error.localizedDescription);
        }else{
            //If there was an error,
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problem contacting server"
                                                            message:@"We're sorry, but there seems to be a network problem. Please try again later"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            alert.tag = 2;
            [alert show];
            NSLog(@"Network error  %@", error.localizedDescription);
        }
    }];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        //Take to login screen
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Register" bundle:nil];
        UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        [window setRootViewController:initViewController];
    }
}

#pragma mark - Form validation helpers

- (void)textFieldChanged
{
    [self updateSubmitButtonEnabledStatus];
}

- (BOOL)isFormValid
{
    NSUInteger numMatches = 0;
    numMatches += self.passwordTextField.text.length > 3 ? 1 : 0;
    numMatches += [self.passwordTextField.text isEqualToString:self.passwordConfirmTextField.text] ? 1 : 0;
    return numMatches > 1;
}

- (void)updateSubmitButtonEnabledStatus
{
    self.setPasswordButton.enabled = [self isFormValid];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.passwordConfirmTextField) {
        [theTextField resignFirstResponder];
    } else if (theTextField == self.passwordTextField) {
        [self.passwordConfirmTextField becomeFirstResponder];
    }
    return YES;
}
@end
