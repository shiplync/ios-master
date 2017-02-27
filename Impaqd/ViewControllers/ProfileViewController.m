//
//  ProfileViewController.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 6/11/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "ProfileViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "VehicleTypeTableViewController.h"
#import "AccountController.h"
#import "TRWebViewController.h"
#import "APISessionManager.h"

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@property (weak, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet SHSPhoneTextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (nonatomic) UIBarButtonItem *cancelButtonItem;
@property (nonatomic) id<AccountProtocol> account;
@property (nonatomic) UIImage *image;

- (IBAction)logoutAction:(id)sender;

@end

@implementation ProfileViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonItemTapped:)];
    
    [self.phoneTextField.formatter setDefaultOutputPattern:@"(###) ###-####"];
    
    self.account = [[[AccountController sharedInstance] activeUserAccount] copyWithZone:NSDefaultMallocZone()];
    [self configureView];
    [self configureImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.view endEditing:!editing];
    [self configureViewEditing:editing];
    if (!editing) {
        [self saveEditsIfNeeded];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"webViewSegue"]) {
        TRWebViewController *webVC = (TRWebViewController *)[segue destinationViewController];
        [webVC setURL:(NSURL *)sender];
    }
}

#pragma mark - UITableViewDelegate Methods

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 4) {
        // Allow Terms of Service and Privacy Policy Cells to be selected when not editing
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"webViewSegue" sender:[[APISessionManager sharedManager] termsOfServiceURL]];
        }
        else if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"webViewSegue" sender:[[APISessionManager sharedManager] privacyPolicyURL]];
        }
    }
    
    
    return nil;
}


#pragma mark - ImagePicker delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (info[UIImagePickerControllerEditedImage]) {
        self.image = info[UIImagePickerControllerEditedImage];
    }
    else if(info[UIImagePickerControllerOriginalImage]) {
        self.image = info[UIImagePickerControllerOriginalImage];
    }
    
    if (self.image) {
        self.imageView.image = self.image;
    }
    
    //    [self dismissViewControllerAnimated:YES completion:^{
    //        [self.navigationController setToolbarHidden:NO animated:YES];
    //    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //    [self dismissViewControllerAnimated:YES completion:^{
    //        [self.navigationController setToolbarHidden:NO animated:YES];
    //    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextField handlers

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return [self isEditing];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (text.length == 0 && textField != self.companyNameTextField) {
        NSString *value;
        if (textField == self.firstNameTextField) {
            value = self.account.firstName;
        }
        else if (textField == self.lastNameTextField) {
            value = self.account.lastName;
        }
        else if (textField == self.phoneTextField) {
            value = [[TRPhoneNumberFormatter defaultFormatter] stringFromPhoneNumber:self.account.phoneNumber phoneNumberStyle:PhoneNumberFormatterStyleNational];
        }
        else if (textField == self.emailTextField) {
            value = self.account.email;
        }
        [self showTextFieldBlankAlert:textField value:value];
        return NO;
    }
    
    if (textField == self.emailTextField) {
        BOOL result = [self validateEmail:self.emailTextField.text strict:NO];
        if (!result) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Invalid Email Address"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               textField.text = self.account.email;
                                                           }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 7;
}

#pragma mark - Private Instance Methods

- (void)configureView {
    [self configureImageView];
    
    self.companyNameTextField.text = [self.account companyName];
    self.firstNameTextField.text = [self.account firstName];
    self.lastNameTextField.text = [self.account lastName];
    self.phoneTextField.text = [[TRPhoneNumberFormatter defaultFormatter] stringFromPhoneNumber:self.account.phoneNumber phoneNumberStyle:PhoneNumberFormatterStyleNational];
    self.emailTextField.text = [self.account email];
}

- (void)configureViewEditing:(BOOL)editing {
    self.navigationItem.leftBarButtonItem = (editing) ? self.cancelButtonItem : nil;
    
    [self.cameraButton setEnabled:editing];
    [self.cameraButton setHidden:!editing];
    
    UITextFieldViewMode viewMode = editing ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
    [self.firstNameTextField setClearButtonMode:viewMode];
    [self.lastNameTextField setClearButtonMode:viewMode];
    [self.phoneTextField setClearButtonMode:viewMode];
    [self.emailTextField setClearButtonMode:viewMode];
}

- (void)configureImageView {
    if (self.imageView.image) {
        return;
    }
    
    if ([self.account profileImageURL] == nil && [self.account respondsToSelector:@selector(photo)] && [self.account photo] != nil) {
        [self.imageView setImage:[self.account photo]];
    }
    else {
        [self.imageView setImageWithURL:[self.account profileImageURL]
                       placeholderImage:[UIImage imageNamed:@"DefaultProfileImage"]];
    }
}

- (void)saveEditsIfNeeded {
    self.account.firstName = self.firstNameTextField.text;
    self.account.lastName = self.lastNameTextField.text;
    self.account.phoneNumber = [[TRPhoneNumberFormatter defaultFormatter] phoneNumberFromString:self.phoneTextField.text];
    self.account.email = self.emailTextField.text;
    //Following condition doesn't work, because activeUserAccount already is the same
    //as self.account
    //if (![self.account isEqual:[[AccountController sharedInstance] activeUserAccount]]) {
    [[APISessionManager sharedManager] patchUsersSelfParameters:[self.account patchParameters]
                                                        success:[self patchSuccessCallback]
                                                        failure:[self patchFailureCallback]];
    //}
    
    if (self.image != nil) {
        [self uploadImage];
    }
}

- (void)uploadImage {
    [[APISessionManager sharedManager] postFile:UIImagePNGRepresentation(self.image)
                                     parameters:nil
                                        success:[self postFileSuccess]
                                        failure:[self postFileFailure]];
}

- (void)cancelButtonItemTapped:(id)sender {
    [super setEditing:NO animated:YES];
    [self configureViewEditing:NO];
    [self configureView];
}

- (IBAction)cameraButtonTapped:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Select Source"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:cancelAction];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera"
                                                           style:UIAlertActionStyleDefault
                                                         handler:[self cameraActionHandler]];
    [alert addAction:cameraAction];
    
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Library"
                                                            style:UIAlertActionStyleDefault
                                                          handler:[self libraryActionHandler]];
    [alert addAction:libraryAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)logoutAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to logout?"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    [alert addAction:noAction];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
														  [[AccountController sharedInstance] logoutWithCompletion:[self logoutAfterTokenRemoveComplete]];
                                                      }];
    [alert addAction:yesAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (TRControllerCallback)logoutAfterTokenRemoveComplete {
	return ^(NSError *error) {
		if(error){
			[self alertTokenRemoveFailure];
			NSLog(@"Unable to remove device token: %@", error.localizedDescription);
			return;
		}
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Register" bundle:nil];
		UIViewController *initViewController = [storyboard instantiateInitialViewController];
		UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
		[window setRootViewController:initViewController];
	};
}

- (void)alertTokenRemoveFailure {
	NSError *error = [NSError errorWithCode:NSURLErrorUserAuthenticationRequired
								description:@"Unable to remove token"
									 reason:@"Please check Internet connection and retry"];
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		UIAlertController *alert = [UIAlertController alertControllerWithError:error];
		[self presentViewController:alert animated:YES completion:^{
			
		}];
	}];
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void (^)(UIAlertAction *))cameraActionHandler {
    return ^(UIAlertAction *action) {
#if TARGET_IPHONE_SIMULATOR
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
#else
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
#endif
    };
}

- (void (^)(UIAlertAction *))libraryActionHandler {
    return ^(UIAlertAction *action) {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    };
}

- (APISessionSuccessBlock)patchSuccessCallback {
    return ^(NSURLSessionDataTask *task, id responseObject) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSDictionary *responseData = (NSDictionary *)responseObject;
            self.account = [[Account alloc] initWithNestedJSONDictionary:responseData];
            [[AccountController sharedInstance] setActiveUserAccount:self.account];
            [self configureView];
        }];
    };
}

- (APISessionFailureBlock)patchFailureCallback {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[[UIAlertView alloc] initWithTitle:@"Problem contacting server"
                                        message:@"We're sorry, but we could not update your account at this time. Please try again."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            self.imageView.image = nil;
            self.account = [[AccountController sharedInstance] activeUserAccount];
            [self configureView];
            
        }];
    };
}

- (APISessionSuccessBlock)postFileSuccess {
    return ^(NSURLSessionDataTask *task, id responseObject) {
        // Add the ProfilePhoto object to the AccountController activeAcccount
        NSError *error;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:responseObject];
        NSString *url = [dict valueForKey:@"url"];
        [dict setValue:url forKey:@"file_url"];
        ProfilePhoto *profilePhoto = [MTLJSONAdapter modelOfClass:[ProfilePhoto class] fromJSONDictionary:dict error:&error];
        [[[AccountController sharedInstance] activeUserAccount] setProfilePhoto:profilePhoto];
    };
}

- (APISessionFailureBlock)postFileFailure {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain]) {
                NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                if (response.statusCode == 406) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Problem saving your photo"
                                                                                   message:@"Sorry, we're having issues saving your photo. You can resubmit your photo now or try again later."
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *now = [UIAlertAction actionWithTitle:@"Retry Now"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
                                                                    [self uploadImage];
                                                                }];
                    [alert addAction:now];
                    
                    UIAlertAction *later = [UIAlertAction actionWithTitle:@"Later"
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction *action) {
                                                                      self.image = nil;
                                                                  }];
                    [alert addAction:later];
                    [self presentViewController:alert animated:YES completion:nil];
                    return;
                }
            }
            UIAlertController *alert = [UIAlertController alertControllerWithError:error];
            [self presentViewController:alert animated:YES completion:^{
                self.image = nil;
                [self configureImageView];
            }];
        }];
    };
}

- (BOOL)validateEmail:(NSString *)email strict:(BOOL)strict {
    static NSString *strictRegex = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    static NSString *looseRegex = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = strict ? strictRegex : looseRegex;
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailPredicate evaluateWithObject:email];
}

- (void)showTextFieldBlankAlert:(UITextField *)textField value:(NSString *)value {
    NSString *message = [NSString stringWithFormat:@"%@ cannot be blank", textField.placeholder];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       textField.text = value;
                                                   }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
