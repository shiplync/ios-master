//
//  ShipmentDetailsTableViewController.m
//  Impaqd
//
//  Created by Traansmission on 6/12/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "ShipmentDetailsTableViewController.h"
#import "ShipmentController.h"
#import "OpenShipmentController.h"
#import "Shipment.h"
#import "APISessionManager.h"

static void * const ShipmentDetailsTableViewControllerKVOContext = (void *)&ShipmentDetailsTableViewControllerKVOContext;


@interface ShipmentDetailsTableViewController ()

@property (nonatomic) ShipmentController *shipmentController;

@end

@implementation ShipmentDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setAccessibilityLabel:NSStringFromClass([self class])];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
	
	if(!self.shipment){
		self.title = @"Shipment No Longer Valid";
	}
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self addObserver:self
           forKeyPath:@"shipment"
              options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
              context:ShipmentDetailsTableViewControllerKVOContext];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.parentViewController setHidesBottomBarWhenPushed:NO];
    [self removeObserver:self forKeyPath:@"shipment" context:ShipmentDetailsTableViewControllerKVOContext];
}


#pragma mark - KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != ShipmentDetailsTableViewControllerKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    if ([keyPath isEqualToString:@"shipment"] && [change[NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeSetting)]) {
        Shipment *shipment = change[NSKeyValueChangeNewKey];
        if ([shipment isEqual:[NSNull null]]) {
            return;
        }
        if (shipment.carrierId != nil) {
            self.navigationItem.rightBarButtonItem = nil;
        }
        self.shipmentController = [[self.controllerClass alloc] initWithShipment:shipment];
        self.tableView.dataSource = self.shipmentController;
        self.tableView.delegate = self.shipmentController;
        [self.tableView reloadData];
    }
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

- (IBAction)shareBarButtonTapped:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Request Shipment"
                                                                   message:@"Send Shipment Request"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:nil];
    [alert addAction:cancelAction];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Request"
                                                       style:UIAlertActionStyleCancel
                                                     handler:[self requestShipmentHandler]];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Private Instance Methods

- (void (^)(UIAlertAction *))requestShipmentHandler {
    return ^(UIAlertAction *action) {
        [[APISessionManager sharedManager] claimShipmentWithId:self.shipment.traansmissionId
                                                    parameters:nil
                                                       success:[self claimShipmentSuccess]
                                                       failure:[self claimShipmentFailure]];
    };
}

- (APISessionSuccessBlock)claimShipmentSuccess {
    return ^(NSURLSessionDataTask *task, id responseObject) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Request Submitted"
                                                                       message:@"You'll be hearing from someone soon!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             [self.navigationController popToRootViewControllerAnimated:YES];
                                                         }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    };
}

- (APISessionFailureBlock)claimShipmentFailure {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
        NSInteger statusCode = [response statusCode];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to claim shipment"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             [self.navigationController popToRootViewControllerAnimated:YES];
                                                         }];
        [alert addAction:okAction];
        if (statusCode==400) {
            [alert setMessage:@"Either someone has just claimed it or you already have an existing shipment."];
        }else{
            [alert setMessage:@"Please try again later."];
        }
        [self presentViewController:alert animated:YES completion:nil];
    };
}

@end
