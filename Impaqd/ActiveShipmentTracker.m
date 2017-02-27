//
//  ActiveShipmentTracker.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/20/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

#import "ActiveShipmentTracker.h"
#import "LocationCoordinator.h"
#import "Shipment.h"
#import "Account.h"
#import "APIOperationManager.h"

@interface ActiveShipmentTracker ()

- (void)saveShipmentStatusToServer;
- (void)sendTrackingUpdateToServer:(CLLocation *)location;

@end

@implementation ActiveShipmentTracker

+ (instancetype)sharedInstance
{
    static ActiveShipmentTracker *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ActiveShipmentTracker alloc] init];
        _sharedInstance.locationCoordinator = [LocationCoordinator sharedInstance];
        _sharedInstance.locationCoordinator.regionEventDelegate = _sharedInstance;
        _sharedInstance.locationCoordinator.trackingDelegate = _sharedInstance;
    });
    return _sharedInstance;
}

- (void)setShipment:(Shipment *)shipment
{
    _shipment = shipment;
    if (shipment == nil) {
        return;
    }
    [self.delegate activeShipmentDidChange:self.shipment];
    [[LocationCoordinator sharedInstance] startTrackingShipment];

    if (self.shipment.pickedUpAt == nil && self.shipment.carrierIsApproved) {
        [[LocationCoordinator sharedInstance] startMonitoringPickUpCoordinate:self.shipment.pickUpCoordinate];
    }
    else if (self.shipment.deliveredAt == nil && self.shipment.carrierIsApproved) {
        [[LocationCoordinator sharedInstance] startMonitoringDeliveryCoordinate:self.shipment.deliveryCoordinate];
    }
    
    [self saveShipmentStatusToServer];
}

- (void) gotoMyShipmentsView
{
    [self.gotoMyShipmentsDelegate gotoMyShipmentsView];
}

- (void)locationCoordinator:(LocationCoordinator *)coordinator didReceiveTrackingUpdateWithLocation:(CLLocation *)location
{
    [self sendTrackingUpdateToServer:location];
}

- (void)didObservePickUpWithLocationCoordinator:(LocationCoordinator *)coordinator
{
    self.shipment.pickedUpAt = [NSDate date];
    [self saveShipmentStatusToServer];

    [self.locationCoordinator stopMonitoringPickUpCoordinate];
    [self.locationCoordinator startMonitoringDeliveryCoordinate:self.shipment.deliveryCoordinate];
    
    [self.delegate activeShipmentPickUpOccurred:self.shipment];
}

- (void)didObserveDeliveryWithLocationCoordinator:(LocationCoordinator *)coordinator
{
    self.shipment.deliveredAt = [NSDate date];
    [self saveShipmentStatusToServer];
    
    [self.locationCoordinator stopMonitoringDeliveryCoordinate];

    [self.delegate activeShipmentDeliveryOccurred:self.shipment];

    // release shipment: no longer active
    self.shipment = nil;
}

#pragma mark - Private server communication helpers

- (void)saveShipmentStatusToServer
{
    NSNumberFormatter *numberFmt = [[NSNumberFormatter alloc] init];
    [numberFmt setNumberStyle:NSNumberFormatterDecimalStyle];
    //NSNumber *carrierId = [numberFmt numberFromString:[[AppAccount activeUserAccount] serverId]];
    
    ISO8601DateFormatter *dateFmt = [[ISO8601DateFormatter alloc] init];
    dateFmt.includeTime = YES;

    NSDictionary *params = @{
        //@"carrier": carrierId ? carrierId : [NSNull null],
        @"picked_up_at": self.shipment.pickedUpAt ? [dateFmt stringFromDate:self.shipment.pickedUpAt] : [NSNull null],
        @"delivered_at": self.shipment.deliveredAt ? [dateFmt stringFromDate:self.shipment.deliveredAt] : [NSNull null],
        @"carrier_set_self": [NSNumber numberWithBool:YES]
    };

    NSString *urlString = [NSString stringWithFormat:@"carriers/shipments/%@/", self.shipment.serverId];
    
    // TODO: notify user on error?
    APIOperationManager *httpManager = [APIOperationManager sharedInstance];
    [httpManager PATCH:urlString
            parameters:params
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   
               }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               
               }];
}

- (void)cancelActiveShipmentWithBlock:(void (^)(NSError*, id))block
{
    if(self.shipment){
        NSDictionary *params = @{
                                 @"carrier_set_none": [NSNumber numberWithBool:YES]
                                 };
        
        NSString *urlString = [NSString stringWithFormat:@"carriers/shipments/%@/", self.shipment.serverId];
        
        // TODO: notify user on error?
        APIOperationManager *httpManager = [APIOperationManager sharedInstance];
        [httpManager PATCH:urlString
                parameters:params
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       block(nil,responseObject);
                       
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       block(error,nil);
                   }];
    }
}

- (void)claimShipmentWithBlock:(void (^)(NSError*, id))block withShipment:(Shipment*)shipment
{
    if(shipment){
        NSDictionary *params = @{
                                 @"carrier_set_self": [NSNumber numberWithBool:YES]
                                 };
        
        NSString *urlString = [NSString stringWithFormat:@"carriers/shipments/%@/", shipment.serverId];
        
        // TODO: notify user on error?
        APIOperationManager *httpManager = [APIOperationManager sharedInstance];
        [httpManager PATCH:urlString
                parameters:params
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       _shipment = shipment;
                       [self.delegate activeShipmentDidChange:self.shipment];
                       //If shipment was succesfully claimed, sync "My Shipments" with server.
                       [self.refreshMyShipmentsDelegate refreshMyShipmentsView];
                       
                       block(nil,responseObject);
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       block(error,nil);
                   }];
    }
}

- (void)sendTrackingUpdateToServer:(CLLocation *)location
{
    NSNumberFormatter *numberFmt = [[NSNumberFormatter alloc] init];
    [numberFmt setNumberStyle:NSNumberFormatterDecimalStyle];

    NSNumber *shipmentId = self.shipment.traansmissionId;

    ISO8601DateFormatter *dateFmt = [[ISO8601DateFormatter alloc] init];
    dateFmt.includeTime = YES;
    
    NSNumber *lat = [NSNumber numberWithDouble:location.coordinate.latitude];
    NSNumber *lng = [NSNumber numberWithDouble:location.coordinate.longitude];

    NSDictionary *params = @{
        //@"carrier": carrierId ? carrierId : [NSNull null],
        @"shipment": shipmentId ? shipmentId : [NSNull null],
        @"timestamp": [dateFmt stringFromDate:[NSDate date]],
        @"coordinate": @{
            @"latitude": lat ? lat : [NSNull null],
            @"longitude": lng ? lng : [NSNull null],
        }
    };
    
    // TODO: notify user on error?
    APIOperationManager *httpManager = [APIOperationManager sharedInstance];
    [httpManager POST:@"tracking/point/"
           parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Unable to send tracking update: %@", error.localizedDescription);
              }];
}

@end
