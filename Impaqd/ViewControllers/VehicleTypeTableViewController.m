//
//  VehicleTypeTableViewController.m
//  Impaqd
//
//  Created by Traansmission on 5/4/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "VehicleTypeTableViewController.h"

static void * const VehicleTypeTableViewControllerKVOContext = (void *)&VehicleTypeTableViewControllerKVOContext;


@interface VehicleTypeTableViewController ()

@end


@implementation VehicleTypeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"VehicleTypeCell"];
    [self addObserver:self forKeyPath:@"selectedVehicleType" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:VehicleTypeTableViewControllerKVOContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"selectedVehicleType" context:VehicleTypeTableViewControllerKVOContext];
}

#pragma mark - KVO Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != VehicleTypeTableViewControllerKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    if ([keyPath isEqualToString:@"activeShipment"] && [change[NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeSetting)]) {
        NSNumber *vehicleNumber = change[NSKeyValueChangeNewKey];
        if ([vehicleNumber isEqual:[NSNull null]]) {
            return;
        }
        self.selectedVehicleType = VehicleTypeFromNSNumber(vehicleNumber);
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return kVehicleTypeCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VehicleTypeCell" forIndexPath:indexPath];
    
    // Configure the cell...
    VehicleType vehicleType = VehicleTypeFromNSNumber(@(indexPath.row+1));
    NSString *vehicleTypeTitle = NSStringFromVehicleType(vehicleType);
    [cell.textLabel setText:vehicleTypeTitle];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (vehicleType == self.selectedVehicleType) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
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


#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Choose Vehicle Type";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedVehicleType = VehicleTypeFromNSNumber(@(indexPath.row+1));
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [self performSegueWithIdentifier:@"unwindToParentViewControllerSegue" sender:self];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"unwindToParentViewControllerSegue"]) {
        UIViewController<VehicleTypeChooserProtocol> *parentVC = (UIViewController<VehicleTypeChooserProtocol> *)segue.destinationViewController;
        parentVC.selectedVehicleType = self.selectedVehicleType;
    }
}

@end
