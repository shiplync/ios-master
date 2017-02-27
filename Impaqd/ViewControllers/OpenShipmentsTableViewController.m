//
//  OpenShipmentsTableViewController.m
//  Impaqd
//
//  Created by Traansmission on 6/3/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "OpenShipmentsTableViewController.h"
#import "AvailableShipmentCell.h"
#import "OpenShipmentsController.h"
#import "OpenShipmentController.h"
#import "ShipmentDetailsTableViewController.h"
#import "ShipmentTableViewCell.h"
#import "SVProgressHUD.h"


@interface OpenShipmentsTableViewController ()

@property (nonatomic) UITableViewCell *bottomLoadMoreCell;
@property (nonatomic) UIActivityIndicatorView *bottomLoadMoreActivityIndicator;
@property (nonatomic) OpenShipmentsController *shipmentsController;
@property (nonatomic) UIView *loadingView;
@property (nonatomic) BOOL isLoading;

@end

@implementation OpenShipmentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    [self setRefreshControl:[[UIRefreshControl alloc] init]];
    [self.refreshControl addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventValueChanged];
    
    UINib *nib = [UINib nibWithNibName:@"ShipmentTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"shipmentCell"];
    
    self.bottomLoadMoreCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BottomRefreshCell"];
    self.bottomLoadMoreCell.textLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomLoadMoreCell.textLabel.text = @"Tap to Load More";

    self.bottomLoadMoreActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.bottomLoadMoreActivityIndicator setHidesWhenStopped:YES];
    [self.bottomLoadMoreCell.contentView addSubview:self.bottomLoadMoreActivityIndicator];
    [self.bottomLoadMoreActivityIndicator stopAnimating];
	
	self.shipmentsController = [[OpenShipmentsController alloc] init];
    [self.shipmentsController performFetchWithCallback:[self fetchCallback]];
	
    self.tableView.estimatedRowHeight = 68.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
//    _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0,0,[[UIScreen mainScreen] applicationFrame].size.width,[[UIScreen mainScreen] applicationFrame].size.height)];
//    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self startLoading];
//    [_loadingView addSubview:indicator];
//    indicator.frame = CGRectMake(0.0, 0.0, 10.0, 10.0);
//    indicator.center = self.view.center;
//    [self.view addSubview:indicator];
//    [indicator bringSubviewToFront:self.view];
//    [indicator startAnimating];
//    [self.view addSubview:_loadingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.shipmentsController numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfShipments = [self.shipmentsController numberOfRowsInSection:section];
    return [self showLoadMoreButton] ? numberOfShipments + 1 : numberOfShipments;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfShipments = [self.shipmentsController numberOfRowsInSection:indexPath.section];
    if (indexPath.row < numberOfShipments) {
        ShipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shipmentCell" forIndexPath:indexPath];
    
        // Configure the cell...
        cell.shipment = [self.shipmentsController shipmentAtIndexPath:indexPath];
    
        return cell;
    }
    else {
        return self.bottomLoadMoreCell;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 172.0f;
//}

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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell == self.bottomLoadMoreCell) {
        [self loadMoreData];
        return;
    }
    Shipment *selectedShipment = [self.shipmentsController shipmentAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"shipmentDetailsSegue" sender:selectedShipment];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"shipmentDetailsSegue"]) {
        ShipmentDetailsTableViewController *shipmentVC = (ShipmentDetailsTableViewController *)segue.destinationViewController;
        [shipmentVC setControllerClass:[OpenShipmentController class]];
        [shipmentVC setHidesBottomBarWhenPushed:YES];
        [shipmentVC setShipment:sender];
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

- (void)refreshButtonAction:(id)sender {
    [self startLoading];
    [self reloadData];
    [self.shipmentsController performFetchWithCallback:^(NSError *error) {
        [self stopLoading];
        [self reloadData];
    }];
}

#pragma mark - Public Instance Methods

- (void)reloadData {
    [self.tableView reloadData];
}


#pragma mark - UIRefreshControl Action Methods

- (void)refreshAction:(id)sender {
    [self.refreshControl beginRefreshing];
    [self.shipmentsController performFetchWithCallback:^(NSError *error) {
        [self.refreshControl endRefreshing];
        [self reloadData];
    }];
}

#pragma mark - Private Instance Methods

- (void)loadMoreData {
    [self.bottomLoadMoreActivityIndicator setFrame:self.bottomLoadMoreCell.bounds];
    [self.bottomLoadMoreCell bringSubviewToFront:self.bottomLoadMoreActivityIndicator];
    [self.bottomLoadMoreCell.textLabel setText:nil];
    [self.bottomLoadMoreActivityIndicator startAnimating];

    [self.shipmentsController fetchMoreWithCompletion:[self moreDataCompletion]];
}

- (TRControllerCallback)moreDataCompletion {
    return ^(NSError *error) {
        [self stopLoading];
        [self.bottomLoadMoreCell.textLabel setText:@"Tap to Load More"];
        [self.bottomLoadMoreActivityIndicator stopAnimating];
        [self.bottomLoadMoreCell sendSubviewToBack:self.bottomLoadMoreActivityIndicator];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (error) {
                UIAlertController *alert = [UIAlertController alertControllerWithError:error];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
            [self reloadData];
        }];
    };
}

- (TRControllerCallback)fetchCallback {
    return ^(NSError *error) {
        [self stopLoading];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (error) {
                UIAlertController *alert = [UIAlertController alertControllerWithError:error];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
            if ([self isViewLoaded]) {
                [self reloadData];
            }
        }];
    };
}

- (void) startLoading
{
    [self.bottomLoadMoreCell setHidden:YES];
    self.isLoading = YES;
    [SVProgressHUD show];
}

- (void) stopLoading
{
    [self.bottomLoadMoreCell setHidden:NO];
    self.isLoading = NO;
    [SVProgressHUD dismiss];
}

- (BOOL) showLoadMoreButton
{
    return self.shipmentsController.hasNext && !self.isLoading;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No shipments";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"You currently don't have any shipments.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return ![self isLoading];
}

@end
