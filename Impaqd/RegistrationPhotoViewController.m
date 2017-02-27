//
//  RegistrationPhotoViewController.m
//  Impaqd
//
//  Created by Traansmission on 5/18/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "RegistrationPhotoViewController.h"
#import "APISessionManager.h"
#import "AccountController.h"

@interface RegistrationPhotoViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

@property (nonatomic) UIImage *image;
@property (nonatomic) UIBarButtonItem *skipButton;
@property (nonatomic) UIBarButtonItem *uploadButton;

@end

@implementation RegistrationPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setHidesBackButton:YES];

    self.uploadButton = [[UIBarButtonItem alloc] initWithTitle:@"Upload"
                                                         style:UIBarButtonItemStylePlain
                                                        target:self action:@selector(uploadButtonTapped:)];
    self.skipButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self action:@selector(skipButtonTapped:)];
    self.navigationItem.rightBarButtonItem = self.skipButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - IBAction Methods

- (IBAction)photoButtonTapped:(id)sender {
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

- (IBAction)uploadButtonTapped:(id)sender {
    [[APISessionManager sharedManager] postFile:UIImagePNGRepresentation(self.image)
                                     parameters:nil
                                        success:[self postFileSuccess]
                                        failure:[self postFileFailure]];
}

- (IBAction)skipButtonTapped:(id)sender {
    [self loadMainViewController];
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
        [self.photoButton setTitle:@"Change Your Profile Picture" forState:UIControlStateNormal];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationItem setRightBarButtonItem:self.uploadButton];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Private Instance Methods

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
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

- (void)loadMainViewController {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *mainVC = [storyBoard instantiateInitialViewController];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window setRootViewController:mainVC];
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
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self loadMainViewController];
        }];
    };
}

- (APISessionFailureBlock)postFileFailure {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain]) {
                NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                if (response.statusCode == 406) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Problem saving your photo"
                                                                                   message:@"Sorry, we're having issues saving your photo. You can resubmit your photo now or later."
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *now = [UIAlertAction actionWithTitle:@"Retry Now"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
                                                                    [self uploadButtonTapped:self];
                                                                }];
                    [alert addAction:now];
                    
                    UIAlertAction *later = [UIAlertAction actionWithTitle:@"Later"
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction *action) {
                                                                      [self skipButtonTapped:self];
                                                                  }];
                    [alert addAction:later];
                    [self presentViewController:alert animated:YES completion:nil];
                    return;
                }
            }
            UIAlertController *alert = [UIAlertController alertControllerWithError:error];
            [self presentViewController:alert animated:YES completion:nil];
        }];
    };
}

@end
