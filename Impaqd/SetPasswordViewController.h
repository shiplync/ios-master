//
//  SetPasswordViewController.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 10/29/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetPasswordViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;
@property (weak, nonatomic) IBOutlet UIButton *setPasswordButton;

- (IBAction)setPasswordAction:(id)sender;

@end
