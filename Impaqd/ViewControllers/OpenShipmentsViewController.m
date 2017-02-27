//
//  OpenShipmentsViewController.m
//  Impaqd
//
//  Created by Traansmission on 6/3/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "OpenShipmentsViewController.h"
#import "MapsViewController.h"
#import "OpenShipmentsTableViewController.h"
#import "LocationCoordinator.h"
#import "OpenShipmentsController.h"
#import "OpenShipmentController.h"

#import "ShipmentDetailsTableViewController.h"
#import "ShipmentFilterViewController.h"


@interface OpenShipmentsViewController ()

@property (nonatomic) OpenShipmentsTableViewController *shipmentsTableViewController;
//@property (nonatomic) OpenShipmentsController *shipmentsController;

@end

@implementation OpenShipmentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setAccessibilityLabel:NSStringFromClass([self class])];
    self.shipmentsTableViewController = [[OpenShipmentsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    self.shipmentsController = [[OpenShipmentsController alloc] init];
//    [self.shipmentsController performFetchWithCallback:[self fetchCallback]];
//    self.shipmentsTableViewController.shipmentsController = self.shipmentsController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"shipmentDetailsSegue"]) {
//        ShipmentDetailsTableViewController *shipmentVC = (ShipmentDetailsTableViewController *)segue.destinationViewController;
//        [shipmentVC setControllerClass:[OpenShipmentController class]];
//        [shipmentVC setHidesBottomBarWhenPushed:YES];
//        [shipmentVC setShipment:sender];
//    }
//}

#pragma mark - Private Instance Methods

//- (TRControllerCallback)fetchCallback {
//    return ^(NSError *error) {
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            if (error) {
//                UIAlertController *alert = [UIAlertController alertControllerWithError:error];
//                [self presentViewController:alert animated:YES completion:nil];
//                return;
//            }
//            if ([self isViewLoaded]) {
//                [self.shipmentsTableViewController reloadData];
//            }
//        }];
//    };
//}

@end
