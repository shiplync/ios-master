//
//  OpenShipmentsController.h
//  Impaqd
//
//  Created by Traansmission on 6/4/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"

@class Shipment;

@interface OpenShipmentsController : NSObject

@property (nonatomic, readonly) BOOL hasPrevious;
@property (nonatomic, readonly) BOOL hasNext;

- (void)performFetchWithCallback:(TRControllerCallback)callback;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (Shipment *)shipmentAtIndexPath:(NSIndexPath *)indexPath;

- (void)fetchNext;
- (void)fetchPrevious;
- (void)fetchMoreWithCompletion:(TRControllerCallback)completion;

- (NSArray *)currentShipments;
- (NSArray *)currentAnnotations;

@end
