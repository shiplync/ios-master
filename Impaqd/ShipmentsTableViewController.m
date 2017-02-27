//
//  ShipmentsTableViewController.m
//  Impaqd
//
//  Created by Traansmission on 4/28/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "ShipmentsTableViewController.h"
#import "ShipmentsController.h"
#import "TraansmissionKit.h"
#import "Shipment.h"
#import "ShipmentCell.h"
#import "ShipmentDetailsTableViewController.h"
#import "ActiveShipmentController.h"

NS_ENUM(NSInteger, ShipmentSegments) {
    ShipmentSegmentActive = 0,
    ShipmentSegmentCompleted = 1,
};

@interface ShipmentsTableViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic) ShipmentsController *shipmentsController;
@property (nonatomic) enum ShipmentCellStyle cellStyle;

@end

@implementation ShipmentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setAccessibilityLabel:NSStringFromClass([self class])];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
    [self.tableView setEstimatedRowHeight:100.0f];
    
    [self.refreshControl addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];

    self.shipmentsController = [[ShipmentsController alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.shipmentsController performFetchWithCallback:[self fetchCallback]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.shipmentsController numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.shipmentsController numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShipmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShipmentCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Shipment *shipment = [self.shipmentsController shipmentAtIndexPath:indexPath];
    [cell setStyle:self.cellStyle];
    [cell setShipment:shipment];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"shipmentDetailsSegue"]) {
        ShipmentDetailsTableViewController *shipmentTVC = (ShipmentDetailsTableViewController *)segue.destinationViewController;
        [shipmentTVC setControllerClass:[ActiveShipmentController class]];
        [shipmentTVC setHidesBottomBarWhenPushed:YES];
        ShipmentCell *shipmentCell = (ShipmentCell *)sender;
        [shipmentTVC setShipment:shipmentCell.shipment];
    }
}

#pragma mark - Private Instance Methods

- (void)refreshTableView:(id)sender {
    [self.refreshControl beginRefreshing];
    [self.shipmentsController performFetchWithCallback:[self fetchCallback]];
}

- (void)segmentedControlChanged:(id)sender {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case ShipmentSegmentActive:
            [self.shipmentsController setActiveShipments];
            self.cellStyle = ShipmentCellStyleActive;
            [self.tableView reloadData];
            break;

        case ShipmentSegmentCompleted:
            [self.shipmentsController setCompletedShipments];
            self.cellStyle = ShipmentCellStyleComplete;
            [self.tableView reloadData];
            break;
    }
}

- (TRControllerCallback)fetchCallback {
    return ^(NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (error) {
                UIAlertController *alert = [UIAlertController alertControllerWithError:error];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
            if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
            if ([self isViewLoaded]) {
                [self segmentedControlChanged:self];
            }
        }];
    };
}

@end
