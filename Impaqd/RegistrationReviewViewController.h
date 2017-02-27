//
//  RegistrationReviewViewController.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/10/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Account;

@interface RegistrationReviewViewController : UITableViewController

@property (nonatomic, strong) Account *accountInProgress;

@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *licenseLabel;
@property (weak, nonatomic) IBOutlet UILabel *vehicleLabel;

@end
