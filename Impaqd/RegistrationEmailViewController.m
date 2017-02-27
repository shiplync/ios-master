//
//  RegistrationEmailViewController.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/10/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "RegistrationEmailViewController.h"
#import "RegistrationLicenseViewController.h"
#import "Account.h"

@interface RegistrationEmailViewController ()  {
    NSRegularExpression *emailRegex;
}

// private methods for form validation
- (BOOL)isFormValid;
- (IBAction)textFieldChanged:(id)sender;
- (void)updateNextButtonEnabledStatus;

@end


@implementation RegistrationEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Do any additional setup after loading the view.
    
    // super basic email regex
    emailRegex = [NSRegularExpression regularExpressionWithPattern:@"\\S+\\@\\S+\\.\\S+" options:0 error:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.emailTextField becomeFirstResponder];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self updateNextButtonEnabledStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender  {
    if ([segue.identifier isEqualToString:@"moveToNextScreen"]) {
        RegistrationLicenseViewController *vc = (RegistrationLicenseViewController *)segue.destinationViewController;
        vc.accountInProgress = self.accountInProgress;
    }
}


#pragma mark - Property Overrides

- (Account *)accountInProgress {
    if (nil == _accountInProgress) {
        _accountInProgress = [[Account alloc] init];
    }
    return _accountInProgress;
}


#pragma mark - UITextField handlers

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (theTextField == self.passwordTextField) {
        [self.confirmationTextField becomeFirstResponder];
    }
    else if (theTextField == self.confirmationTextField) {
        [theTextField resignFirstResponder];
        [self nextTapped:nil];
    }
    return YES;
}

- (IBAction)textFieldChanged:(id)sender {
    [self updateNextButtonEnabledStatus];
}

#pragma mark - Button handlers

- (IBAction)nextTapped:(__unused id)sender {
    if (self.isFormValid) {
        NSString *password = self.passwordTextField.text;
        NSString *confirm = self.confirmationTextField.text;
        if (![password isEqualToString:confirm]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Passwords Mismatch"
                                                                           message:@"The Password and Confirmation don't match. Please reenter"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }

        self.accountInProgress.emailAddress = self.emailTextField.text;
        self.accountInProgress.password = self.passwordTextField.text;
        [self performSegueWithIdentifier:@"moveToNextScreen" sender:nil];
    }
}

#pragma mark - Form validation helpers

- (BOOL)isFormValid {
    return [self emailValid] && [self textLengthValid:self.passwordTextField.text] && [self textLengthValid:self.confirmationTextField.text];
}

- (BOOL)emailValid {
    NSUInteger numMatches = [emailRegex numberOfMatchesInString:self.emailTextField.text
                                                        options:0
                                                          range:NSMakeRange(0, self.emailTextField.text.length)];
    return numMatches == 1;
}

- (BOOL)textLengthValid:(NSString *)text {
    return [text length] > 3;
}

- (void)updateNextButtonEnabledStatus {
    self.navigationItem.rightBarButtonItem.enabled = [self isFormValid];
}

@end
