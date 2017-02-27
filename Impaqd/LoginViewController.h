//
//  LoginViewController.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 10/23/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"

@interface LoginViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;
- (IBAction)loginAction:(id)sender;

@end
