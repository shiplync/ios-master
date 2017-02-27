//
//  MapsViewController.m
//  Impaqd
//
//  Created by Traansmission on 6/3/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "MapsViewController.h"
#import "PermissionsController.h"
#import "OpenShipmentsController.h"
#import "LocationCoordinator.h"

#import "ShipmentAnnotation.h"

#define kDefaultLatitude   40.7509802
#define kDefaultLongitude -73.9888682
#define kDefaultDistance   8.0E4

NS_ENUM(NSInteger, PagingSegments) {
    PagingSegmentPrevious  = 0,
    PagingSegmentNext = 1,
};

static void * const MapsViewControllerKVOContext = (void *)&MapsViewControllerKVOContext;

@interface MapsViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *pagingSegmentedControl;
@property (weak, nonatomic) LocationCoordinator *locationCoordinator;

@end

@implementation MapsViewController


#pragma mark - Object Lifecycle

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"_locationCoordinator.authorizationStatus" context:MapsViewControllerKVOContext];
}


#pragma mark - UIViewController Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.locationCoordinator = [LocationCoordinator sharedInstance];

    [self.mapView setRegion:[self defaultRegion] animated:NO];
    [self.mapView setCenterCoordinate:[self defaultCenter] animated:NO];
    
    [self addObserver:self
           forKeyPath:@"_locationCoordinator.authorizationStatus"
              options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
              context:MapsViewControllerKVOContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - KVO Method

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != MapsViewControllerKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if ([keyPath isEqualToString:@"_locationCoordinator.authorizationStatus"] && [change[NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeSetting)]) {
        [self.mapView setShowsUserLocation:[self.locationCoordinator isEnabledWhileInUse]];
    }
}


#pragma mark - MKMapViewDelegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView;
    if ([annotation isKindOfClass:[ShipmentAnnotation class]]) {
        annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ShipmentAnnotation"];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ShipmentAnnotation"];
        }
        else {
            annotationView.annotation = annotation;
        }
        annotationView.animatesDrop = NO;
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
        
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    ShipmentAnnotation *annotation = (ShipmentAnnotation *)view.annotation;
    Shipment *shipment = annotation.shipment;
//    [self.parentViewController performSegueWithIdentifier:@"shipmentDetailSegue" sender:shipment];
    [self.parentViewController performSegueWithIdentifier:@"shipmentDetailsSegue" sender:shipment];
}


#pragma mark - IBAction Methods

- (IBAction)pagingSegmentedControlTapped:(id)sender {
    switch (self.pagingSegmentedControl.selectedSegmentIndex) {
        case PagingSegmentPrevious:
            [self.shipmentsController fetchPrevious];
            break;
            
        case PagingSegmentNext:
            [self.shipmentsController fetchNext];
            break;
    }
}


#pragma mark - Public Instance Methods

- (IBAction)centerOnUserLocation:(id)sender {
    if ([self.mapView showsUserLocation]) {
        CLLocation *userLocation = [[self.mapView userLocation] location];
        [self.mapView setCenterCoordinate:[userLocation coordinate] animated:YES];
    }
}

- (void)reloadData {
    [self.mapView removeAnnotations:[self.mapView annotations]];
    NSArray *currentAnnotations = [self.shipmentsController currentAnnotations];
    if (currentAnnotations != nil) {
        [self.mapView addAnnotations:currentAnnotations];
    }
    [self.pagingSegmentedControl setEnabled:[self.shipmentsController hasPrevious] forSegmentAtIndex:PagingSegmentPrevious];
    [self.pagingSegmentedControl setEnabled:[self.shipmentsController hasNext] forSegmentAtIndex:PagingSegmentNext];
}


#pragma mark - Private Instance Methods

- (CLLocationCoordinate2D)defaultCenter {
    return CLLocationCoordinate2DMake(kDefaultLatitude, kDefaultLongitude);
}

- (MKCoordinateRegion)defaultRegion {
    return MKCoordinateRegionMakeWithDistance([self defaultCenter], kDefaultDistance, kDefaultDistance);
}

@end
