//
//  RootViewController.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 10/7/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "RootViewController.h"
#import "PermissionsViewController.h"
#import "OpenShipmentsViewController.h"

#import "AppDelegate.h"
#import "APNSController.h"
#import "PermissionsController.h"

NS_ENUM(NSInteger, RootController) {
    RootControllerOpen = 0,
    RootControllerActive,
    RootControllerContact,
    RootControllerProfile
};

@interface RootViewController ()

@property (nonatomic) PermissionsViewController *permissionsViewController;

@end

@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	
	BOOL need_init_permission = [[NSUserDefaults standardUserDefaults] boolForKey:@"need_init_permission"];
	if(need_init_permission){
		self.permissionsViewController = [[PermissionsViewController alloc] initWithCompletion:[self permissionsCompletion]];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"need_init_permission"];
	}
	
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.permissionsViewController) {
        [self.selectedViewController presentViewController:self.permissionsViewController
                                                  animated:NO
                                                completion:nil];
    }
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [self.selectedViewController presentViewController:viewControllerToPresent animated:flag completion:completion];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Public Instance Methods

- (void)presentShipmentDetails:(Shipment *)shipment {
    [self setSelectedIndex:RootControllerOpen];
    UINavigationController *navigationVC = (UINavigationController *)[self selectedViewController];
    NSArray *childViewControllers = [navigationVC childViewControllers];
    OpenShipmentsViewController *openShipmentsVC = [childViewControllers firstObject];
    [openShipmentsVC performSegueWithIdentifier:@"shipmentDetailsSegue" sender:shipment];
}

- (void)presentActiveShipments {
    [self setSelectedIndex:RootControllerActive];
}

#pragma mark - Private Instance Methods

- (TRControllerCallback)permissionsCompletion {
    return ^(NSError *error) {
        if (error) {
            [self handlePermissionError:error];
            return;
        }
        [self dismissPermissionsViewController];
    };
}

- (void)dismissPermissionsViewController {
    [self.selectedViewController dismissViewControllerAnimated:YES completion:nil];
    self.permissionsViewController = nil;
}

- (void)handlePermissionError:(NSError *)error {
    if (![error.domain isEqualToString:TRErrorDomain]) {
        UIAlertController *alert = [UIAlertController alertControllerWithError:error];
        [self.permissionsViewController presentViewController:alert animated:YES completion:^{ [self dismissPermissionsViewController]; }];
    }
    switch (error.code) {
        case TRErrorLocationServicesDenied:
        case TRErrorLocationServicesLimited:
            [self handleLocationPermissionError];
            break;
        
        default: {
            UIAlertController *alert = [UIAlertController alertControllerWithError:error];
            [self.permissionsViewController presentViewController:alert animated:YES completion:^{ [self dismissPermissionsViewController]; }];
            break;
        }
    }
}

- (void)handleLocationPermissionError {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location Permissions Needed"
                                                                   message:@"In order to best use Traansmission, open the application settings. Select \"Location\" and select \"Always\"."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"Not Now"
                                                          style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction *action){ [self dismissPermissionsViewController]; }];
    [alert addAction:laterAction];
    UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"Open Settings"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {
                                                           [self dismissPermissionsViewController];
                                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                       }];
    [alert addAction:openAction];
    [self.permissionsViewController presentViewController:alert animated:YES completion:nil];
}

//- (void)verifyPermissions {
//    PermissionsController *permissionsController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] permissionsController];
//    if (!permissionsController.isRegisteredForUserNotificationSettings) {
//        [permissionsController registerForUserNotificationSettings:[self userNotificationsCompletion]];
//    }
//    else if (!permissionsController.isRegisteredForRemoteNotifications) {
//        [permissionsController registerForRemoteNotifications:[self remoteNotificationsCompletion]];
//    }
//    else if (!permissionsController.isRegisteredForLocationServices) {
//        [permissionsController registerForLocationServices:[self locationServicesCompletion]];
//    }
//}
//
//- (void)verifyRemoteNotificationPermissions {
//    PermissionsController *permissionsController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] permissionsController];
//    if (!permissionsController.isRegisteredForRemoteNotifications) {
//        [permissionsController registerForRemoteNotifications:[self remoteNotificationsCompletion]];
//    }
//}
//
//- (void)verifyLocationServicePermissions {
////    PermissionsController *permissionsController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] permissionsController];
////    if (!permissionsController.isRegisteredForLocationServices) {
////        if ([permissionsController isLocationServiceDenied]) {
////            [self locationServicesCompletion]([NSError errorWithCode:TRErrorLocationServicesDenied description:@"Location Services Required"]);
////        }
////        else if ([permissionsController isLocationServiceLimited]) {
////            [self locationServicesCompletion]([NSError errorWithCode:TRErrorLocationServicesLimited description:@"Location Services Required"]);
////        }
////        else {
////            [permissionsController registerForLocationServices:[self locationServicesCompletion]];
////        }
////    }
//}
//
//- (TRControllerCallback)userNotificationsCompletion {
//    return ^(NSError *error) {
//        if (error) {
//            if (error.code == TRErrorUserNotificationsDenied) {
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Permissions Needed"
//                                                                               message:@"In order to best use Traansmission, open the application settings. Select \"Notifications\" and \"Allow Notifications\". Enable \"Sounds\", \"Badge App Icon\", and \"Show on Lock Screen\""
//                                                                        preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"Not Now"
//                                                                     style:UIAlertActionStyleDestructive
//                                                                    handler:^(UIAlertAction *action) {
//                                                                        [self verifyRemoteNotificationPermissions];
//                                                                    }];
//                [alert addAction:laterAction];
//                UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"Open Settings"
//                                                                     style:UIAlertActionStyleCancel
//                                                                   handler:^(UIAlertAction *action) {
//                                                                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//                                                                   }];
//                [alert addAction:openAction];
//                [self presentViewController:alert animated:YES completion:nil];
//                return;
//            }
//        }
//        [self verifyRemoteNotificationPermissions];
//    };
//}
//
//- (TRControllerCallback)remoteNotificationsCompletion {
//    return ^(NSError *error) {
//        if (error) {
//            if (error.code == TRErrorRemoteNotificationsDenied) {
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Permissions Needed"
//                                                                               message:@"In order to best use Traansmission, open the application settings and allow Remote Notifications"
//                                                                        preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"Not Now"
//                                                                      style:UIAlertActionStyleDestructive
//                                                                    handler:^(UIAlertAction *action) {
//                                                                        [self verifyLocationServicePermissions];
//                                                                    }];
//                [alert addAction:laterAction];
//                UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"Open Settings"
//                                                                     style:UIAlertActionStyleCancel
//                                                                   handler:^(UIAlertAction *action) {
//                                                                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//                                                                   }];
//                [alert addAction:openAction];
//                [self presentViewController:alert animated:YES completion:nil];
//                return;
//            }
//        }
//        [self verifyLocationServicePermissions];
//    };
//}
//

@end
