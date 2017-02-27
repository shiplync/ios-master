//
//  RegistrationLicenseViewController.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/10/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHSPhoneLibrary.h"
#import "VehicleTypeTableViewController.h"

@class Account;

@interface RegistrationLicenseViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, VehicleTypeChooserProtocol>

@property (nonatomic, strong) Account *accountInProgress;

- (IBAction)nextTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet SHSPhoneTextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *licenseTextField;
@property (weak, nonatomic) IBOutlet UILabel *primaryVehicleLabel;

@end
