//
//  ShipmentsController.m
//  Impaqd
//
//  Created by Traansmission on 4/28/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "ShipmentsController.h"
#import "APISessionManager.h"
#import "Shipment.h"

@interface ShipmentsController ()

@property (nonatomic) NSArray *shipments;
@property (nonatomic) NSArray *activeShipments;
@property (nonatomic) NSArray *completedShipments;

@end

@implementation ShipmentsController

- (void)performFetchWithCallback:(TRControllerCallback)callback {
    [[APISessionManager sharedManager] carriersShipmentsTempWithParameters:nil
                                                                   success:[self tempSuccessBlockWithCallback:callback]
                                                                   failure:[self failureBlockWithCallback:callback]];
}

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return [self.shipments count];
}

- (Shipment *)shipmentAtIndexPath:(NSIndexPath *)indexPath {
    return self.shipments[indexPath.row];
}

- (void)setActiveShipments {
    self.shipments = self.activeShipments;
}

- (void)setCompletedShipments {
    self.shipments = self.completedShipments;
}

#pragma mark - Private Instance Methods

- (APISessionSuccessBlock)successBlockWithCallback:(TRControllerCallback)callback {
    return ^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *shipmentsJSONArray = (NSArray *)responseObject;
        NSMutableArray *activeShipmentsArray = [NSMutableArray array];
        NSMutableArray *completedShipmentsArray = [NSMutableArray array];
        for (NSDictionary *shipmentJSONDict in shipmentsJSONArray) {
            Shipment *shipment = [[Shipment alloc] initWithJSONAttributes:shipmentJSONDict];
            if (shipment.deliveredAt) {
                [completedShipmentsArray addObject:shipment];
            }
            else {
                [activeShipmentsArray addObject:shipment];
            }
        }
        self.activeShipments = [NSArray arrayWithArray:activeShipmentsArray];
        self.completedShipments = [NSArray arrayWithArray:completedShipmentsArray];
        if (callback) {
            callback(nil);
        }
    };
}

- (APISessionFailureBlock)failureBlockWithCallback:(TRControllerCallback)callback {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        if (callback) {
            callback(error);
        }
    };
}

- (APISessionSuccessBlock)tempSuccessBlockWithCallback:(TRControllerCallback)callback {
    return ^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *paginatedShipmentsJSON = (NSDictionary *)responseObject;
        NSNumber *count = paginatedShipmentsJSON[@"count"];
        NSString *previousURLString = paginatedShipmentsJSON[@"previous"];
        NSString *nextURLString = paginatedShipmentsJSON[@"next"];
        NSArray *shipmentsJSONArray = paginatedShipmentsJSON[@"results"];

        NSMutableArray *activeShipmentsArray = [NSMutableArray array];
        NSMutableArray *completedShipmentsArray = [NSMutableArray array];
        for (NSDictionary *shipmentJSONDict in shipmentsJSONArray) {
            Shipment *shipment = [[Shipment alloc] initWithJSONAttributes:shipmentJSONDict];
            if (shipment.deliveredAt) {
                [completedShipmentsArray addObject:shipment];
            }
            else {
                [activeShipmentsArray addObject:shipment];
            }
        }
        self.activeShipments = [NSArray arrayWithArray:activeShipmentsArray];
        self.completedShipments = [NSArray arrayWithArray:completedShipmentsArray];
        if (callback) {
            callback(nil);
        }
    };
}

@end
