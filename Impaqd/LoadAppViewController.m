//
//  LoadAppViewController.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 7/20/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "LoadAppViewController.h"
#import "InitializerController.h"
#import "SVProgressHUD.h"

@interface LoadAppViewController ()

@property (copy) InitializerCallback initializerCallback;
@property (nonatomic) InitializerController *initializerController;

@end

@implementation LoadAppViewController

#pragma mark - Object Lifecycle

- (instancetype)initWithCallback:(InitializerCallback)callback {
    self = [super init];
    if (self) {
        self.initializerCallback = callback;
    }
    return self;
}


#pragma mark - UIViewController Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.initializerController = [[InitializerController alloc] initWithCallback:[self callback]];
    
    UINib *launchScreenNib = [UINib nibWithNibName:@"LaunchScreen" bundle:nil];
    UIView *launchScreen = [[launchScreenNib instantiateWithOwner:nil options:nil] firstObject];
    [launchScreen setFrame:self.view.frame];
    [self.view addSubview:launchScreen];
    [self.view bringSubviewToFront:launchScreen];
    
    [self setModalPresentationStyle:UIModalPresentationOverCurrentContext];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SVProgressHUD show];
    [self.initializerController didFinishLaunching];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [SVProgressHUD dismiss];
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [super dismissViewControllerAnimated:flag completion:completion];
    [SVProgressHUD show];
}

#pragma mark - Private Instance Methods

- (InitializerCallback)callback {
    return ^(NSError *error) {
        if (error) {
            if ([error.domain isEqualToString:TRErrorDomain]) {
                if (error.code == TRErrorVersionCheckFailed) {
                    self.initializerCallback(error);
                    return;
                } else if (error.code == NSURLErrorUserAuthenticationRequired) {
                    self.initializerCallback(error);
                    return;
                }
            }
            UIAlertController *alert = [UIAlertController alertControllerWithError:error];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        self.initializerCallback(nil);
    };
}

@end
