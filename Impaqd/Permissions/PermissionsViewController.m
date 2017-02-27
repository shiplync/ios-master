//
//  PermissionsViewController.m
//  Impaqd
//
//  Created by Traansmission on 6/8/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "PermissionsViewController.h"
#import "PermissionsController.h"

#import "UserNotificationsPermissions.h"
#import "RemoteNotificationsPermissions.h"
#import "LocationManagerPermissions.h"

@interface PermissionsViewController ()

@property (nonatomic, copy) TRControllerCallback completion;
@property (nonatomic, readwrite) PermissionsController *permissionsController;

@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) dispatch_semaphore_t semaphore;


@end

@implementation PermissionsViewController

- (instancetype)initWithCompletion:(TRControllerCallback)completion {
    self = [super init];
    if (self) {
        self.completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setAccessibilityLabel:NSStringFromClass([self class])];
    
    UINib *launchScreenNib = [UINib nibWithNibName:@"LaunchScreen" bundle:nil];
    UIView *launchScreen = [[launchScreenNib instantiateWithOwner:nil options:nil] firstObject];
    [launchScreen setFrame:self.view.frame];
    [self.view addSubview:launchScreen];
    [self.view bringSubviewToFront:launchScreen];
    
    [self setModalPresentationStyle:UIModalPresentationOverCurrentContext];

    self.queue = dispatch_queue_create([NSStringFromClass([self class]) UTF8String], DISPATCH_QUEUE_SERIAL);

    [PermissionsController registerClass:[UserNotificationsPermissions class]];
    [PermissionsController registerClass:[RemoteNotificationsPermissions class]];
    [PermissionsController registerClass:[LocationManagerPermissions class]];
    self.permissionsController = [[PermissionsController alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.permissionsController registerForPermissions:self.completion];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
