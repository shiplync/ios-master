//
//  RegistrationReviewViewController.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/10/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "RegistrationReviewViewController.h"
#import "APISessionManager.h"
#import "Account.h"
#import <Mixpanel/Mixpanel.h>

#import "TRJSONResponseSerializer.h"
#import "TRWebViewController.h"
#import "AccountController.h"
#import "RegistrationPhotoViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface RegistrationReviewViewController ()

@property (nonatomic) UIBarButtonItem *doneButton;
@property (nonatomic) UIBarButtonItem *spinnerButton;

- (void)doneTapped;
- (void)configureView;

- (void)accountConfirmed:(Account *)account;
- (void)requestAppAccountFromServer:(Account *)account;

@end

@implementation RegistrationReviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    UIActivityIndicatorView *spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinnerButton = [[UIBarButtonItem alloc] initWithCustomView:spinnerView];

    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"webViewSegue"]) {
        TRWebViewController *webVC = (TRWebViewController *)[segue destinationViewController];
        [webVC setURL:(NSURL *)sender];
    }
}


#pragma mark - Property Overrides

- (void)setAccountInProgess:(Account *)account {
    _accountInProgress = account;
    [self configureView];
}

- (void)doneTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Terms of Service"
                                                                   message:@"By selecting Register, you agree to our Terms of Service and Privacy Policy"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *tosAction = [UIAlertAction actionWithTitle:@"Terms of Service"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [self performSegueWithIdentifier:@"webViewSegue" sender:[[APISessionManager sharedManager] termsOfServiceURL]];
                                                      }];
    [alert addAction:tosAction];

    UIAlertAction *ppAction = [UIAlertAction actionWithTitle:@"Privacy Policy"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [self performSegueWithIdentifier:@"webViewSegue" sender:[[APISessionManager sharedManager] privacyPolicyURL]];
                                                      }];
    [alert addAction:ppAction];
    
    UIAlertAction *registerAction = [UIAlertAction actionWithTitle:@"Register"
                                                             style:UIAlertActionStyleCancel
                                                           handler:^(UIAlertAction *action) {
                                                               [self requestAppAccountFromServer:self.accountInProgress];

                                                               //ANALYTICS START
                                                               Mixpanel *mixpanel = [Mixpanel sharedInstance];
                                                               [mixpanel track:@"finished registration" properties:@{ @"email": self.accountInProgress.emailAddress,
                                                                                                                      @"license": self.accountInProgress.licenseNumber,
                                                                                                                      @"vehicle": NSStringFromVehicleType(self.accountInProgress.vehicleType) }];
                                                               //ANALYTICS END
                                                           }];
    [alert addAction:registerAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)configureView {
    self.companyNameLabel.text = self.accountInProgress.companyName;
    self.emailLabel.text = self.accountInProgress.emailAddress;
    self.licenseLabel.text = self.accountInProgress.licenseNumber;
    self.firstNameLabel.text = self.accountInProgress.firstName;
    self.lastNameLabel.text = self.accountInProgress.lastName;
    self.phoneLabel.text = [[TRPhoneNumberFormatter defaultFormatter] stringFromPhoneNumber:self.accountInProgress.phoneNumber phoneNumberStyle:PhoneNumberFormatterStyleNational];
    
    NSString *labelText = NSStringFromVehicleType(self.accountInProgress.vehicleType);
    if (!labelText.length) {
        labelText = @"--";
    }
    self.vehicleLabel.text = labelText;
}

- (void)accountConfirmed:(Account *)account {
    [SVProgressHUD dismiss];
    [[AccountController sharedInstance] setActiveUserAccount:account];
    [self performSegueWithIdentifier:@"registerPhotoSegue" sender:self];
}

- (void)requestAppAccountFromServer:(Account *)account {
    [SVProgressHUD show];
    [self setNavigationEnabled:NO];
    [[AccountController sharedInstance] registerAccount:account completion:[self registrationCompletion]];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Register" bundle:nil];
        UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        [window setRootViewController:initViewController];
    }
}

- (void)setNavigationEnabled:(BOOL)enabled {
    self.navigationItem.hidesBackButton = !enabled;
    self.navigationItem.rightBarButtonItem = (enabled) ? self.doneButton : self.spinnerButton;
}

#pragma mark - Private Instance Methods

- (TRControllerCallback)registrationCompletion {
    return ^(NSError *error) {
        if (error) {
            [SVProgressHUD dismiss];
            if ([error.domain isEqualToString:TRErrorDomain] && error.code == TRErrorRegistration) {
                NSString *title = error.userInfo[NSLocalizedDescriptionKey];
                NSString *message = error.userInfo[NSLocalizedFailureReasonErrorKey];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self setNavigationEnabled:YES];
                    [[[UIAlertView alloc] initWithTitle:title
                                                message:message
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                    
                }];
            }
            else {
                UIAlertController *alert = [UIAlertController alertControllerWithError:error];
                [self presentViewController:alert animated:YES completion:nil];
            }
            return;
        }
        [[AccountController sharedInstance] acceptTOSWithCompletion:[self acceptTOSCompletion]];
    };
}

- (TRControllerCallback)acceptTOSCompletion {
    return ^(NSError *error) {
        if (error) {
            [SVProgressHUD dismiss];
            UIAlertController *alert = [UIAlertController alertControllerWithError:error];
            [self presentViewController:alert animated:YES completion:nil];
        }
        self.navigationItem.rightBarButtonItem = nil;
        [self accountConfirmed:[[AccountController sharedInstance] activeUserAccount]];
    };
}

@end
