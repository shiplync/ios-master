//
//  RegistrationEmailViewController.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/10/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Account;

@interface RegistrationEmailViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) Account *accountInProgress;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmationTextField;

- (IBAction)nextTapped:(id)sender;

@end
