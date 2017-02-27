//
//  RegistrationLicenseViewController.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/10/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "RegistrationLicenseViewController.h"
#import "RegistrationReviewViewController.h"
#import "Account.h"

@interface RegistrationLicenseViewController ()

- (BOOL)isFormValid;
- (IBAction)textFieldChanged:(id)sender;
- (void)updateNextButtonEnabledStatus;
- (void)updatePrimaryVehicleLabel;

@end

@implementation RegistrationLicenseViewController

@synthesize selectedVehicleType;

- (void)viewDidLoad {
    [super viewDidLoad];
    //Do any additional setup after loading the view.
    [self.phoneTextField.formatter setDefaultOutputPattern:@"(###) ###-####"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updatePrimaryVehicleLabel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self isMovingToParentViewController]) {
        if ([self.companyNameTextField.text length] == 0) {
            [self.companyNameTextField becomeFirstResponder];
        }
    }
    [self updateNextButtonEnabledStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.licenseTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"moveToNextScreen"]) {
        RegistrationReviewViewController *vc = (RegistrationReviewViewController *)segue.destinationViewController;
        vc.accountInProgress = self.accountInProgress;
    }
    else if ([segue.identifier isEqualToString:@"chooseVehicleSegue"]) {
        VehicleTypeTableViewController *vehicleTypeTVC = (VehicleTypeTableViewController *)segue.destinationViewController;
        vehicleTypeTVC.selectedVehicleType = self.selectedVehicleType;
    }
}


#pragma mark - UITextField handlers

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.companyNameTextField) {
        [self.firstNameTextField becomeFirstResponder];
    }
    else if (theTextField == self.firstNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
    }
    else if (theTextField == self.lastNameTextField) {
        [self.phoneTextField becomeFirstResponder];
    }
    else if (theTextField == self.phoneTextField) {
        [self.licenseTextField becomeFirstResponder];
    }
    else if (theTextField == self.licenseTextField) {
        [theTextField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.length + range.location > textField.text.length) {
        return NO;
    }

    if (textField != self.licenseTextField) {
        return YES;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 7;
}

- (IBAction)textFieldChanged:(id)sender {
    [self updateNextButtonEnabledStatus];
}

#pragma mark - Button handlers

- (IBAction)nextTapped:(__unused id)sender
{
    if (self.isFormValid) {
        self.accountInProgress.companyName = self.companyNameTextField.text;
        self.accountInProgress.firstName = self.firstNameTextField.text;
        self.accountInProgress.lastName = self.lastNameTextField.text;
        self.accountInProgress.phoneNumber = [[TRPhoneNumberFormatter defaultFormatter] phoneNumberFromString:self.phoneTextField.text];
        self.accountInProgress.licenseNumber = self.licenseTextField.text;
        self.accountInProgress.vehicleType = self.selectedVehicleType;
        [self performSegueWithIdentifier:@"moveToNextScreen" sender:nil];
    }
}

#pragma mark - Form validation helpers

- (BOOL)isFormValid {
    BOOL isTextValid = self.companyNameTextField.text.length > 0 &&
        self.licenseTextField.text.length > 3 &&
        self.firstNameTextField.text.length > 0 &&
        self.lastNameTextField.text.length > 0 &&
        self.phoneTextField.text.length > 8;
    return isTextValid;
}

- (void)updateNextButtonEnabledStatus {
    self.navigationItem.rightBarButtonItem.enabled = [self isFormValid];
}

- (void)updatePrimaryVehicleLabel {
    self.selectedVehicleType = self.accountInProgress.vehicleType;
    self.primaryVehicleLabel.text = NSStringFromVehicleType(self.selectedVehicleType);
}

- (IBAction)unwindFromVehicleTypeTableViewController:(UIStoryboardSegue *)segue {
    self.accountInProgress.vehicleType = self.selectedVehicleType;
}

@end
