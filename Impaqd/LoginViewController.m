//
//  LoginViewController.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 10/23/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "LoginViewController.h"
#import "AccountController.h"
#import "sharedConstants.h"
#import "APISessionManager.h"
#import <SSKeychain/SSKeychain.h>
#import "AppDelegate.h"
#import "APIOperationManager.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Belt and Suspenders for clearing out the Auth Token
    [SSKeychain deletePasswordForService:TOKEN_LOGIN account:DEFAULT_ACCOUNT];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.loginButton setEnabled:YES];
    [self.emailText becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
#pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)loginAction:(id)sender {
	[[AccountController sharedInstance] localLogout];
	[self.loginButton setEnabled:NO];
	NSDictionary *parameters = @{ @"username" : self.emailText.text,
								  @"password" : self.passwordText.text };
	[[AccountController sharedInstance] loginWithParameters:parameters
												 completion:[self loginCompletion]];
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.passwordText) {
        [theTextField resignFirstResponder];
    } else if (theTextField == self.emailText) {
        [self.passwordText becomeFirstResponder];
    }
    return YES;
}


#pragma mark - Private Instance Methods

- (TRControllerCallback)loginCompletion {
    return ^(NSError *error) {
        if (error) {
            if ([error.domain isEqualToString:TRErrorDomain]) {
                switch (error.code) {
                    case NSURLErrorUserAuthenticationRequired:
                        [self alertLoginFailure];
                        return;
                        break;
                        
                    case TRErrorInvalidAccountType:
                        [self alertWrongUserType];
                        return;
                        break;
                }
            }
            UIAlertController *alert = [UIAlertController alertControllerWithError:error];
            [self presentViewController:alert animated:YES completion:^{
                [self.loginButton setEnabled:YES];
            }];
            return;
        }
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"need_init_permission"];
		[self presentRootViewController];
    };
}

- (APISessionFailureBlock)registerDeviceTokenFailureCallback {
	return ^(NSURLSessionDataTask *task, NSError *error) {
		if (error) {
			NSLog(@"Unable to register device token: %@", error.localizedDescription);
			return;
		}
	};
}

- (void)alertLoginFailure {
    NSError *error = [NSError errorWithCode:NSURLErrorUserAuthenticationRequired
                                description:@"Wrong login information"
                                     reason:@"Please check your username and password"];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIAlertController *alert = [UIAlertController alertControllerWithError:error];
        [self presentViewController:alert animated:YES completion:^{
            [self.loginButton setEnabled:YES];
        }];
    }];
}

- (void)alertWrongUserType {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not a Carrier"
                                                                       message:@"Your Traansmission Account is not a Carrier. Please try another account."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:^{
            [self.loginButton setEnabled:YES];
        }];
    }];
}

- (void)presentRootViewController {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        if ([[[AccountController sharedInstance] activeUserAccount] isVerified]) {
//            UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:@"mainStartVC"];
//            [window setRootViewController:initViewController];
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] showRootViewController];
        }
        else {
            UIViewController *initViewController = [storyboard instantiateInitialViewController];
            [window setRootViewController:initViewController];
        }
    }];
}

@end
