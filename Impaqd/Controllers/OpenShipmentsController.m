//
//  OpenShipmentsController.m
//  Impaqd
//
//  Created by Traansmission on 6/4/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "OpenShipmentsController.h"
#import "APISessionManager.h"
#import "AvailableShipmentSearchParameters.h"
#import "ShipmentAnnotation.h"

@interface OpenShipmentsController ()

@property (nonatomic, copy) TRControllerCallback callback;
@property (nonatomic) NSDictionary *baseParameters;
@property (nonatomic) NSDictionary *nextParameters;

@property (nonatomic) NSMutableArray *pagedShipments;
@property (nonatomic) NSInteger currentPage;

@end

@implementation OpenShipmentsController


#pragma mark - Property Overrides

- (BOOL)hasPrevious {
//    return (self.previousParameters != nil);
    return (self.currentPage > 0);
}

- (BOOL)hasNext {
    return (self.nextParameters != nil)
        || (self.currentPage < [self.pagedShipments count]-1);
}


#pragma mark - Public Instance Methods

- (void)performFetchWithCallback:(TRControllerCallback)callback {
    self.callback = callback;
    self.pagedShipments = [NSMutableArray array];
    self.currentPage = -1;
    [self performFetchWithParameters:self.baseParameters callback:callback];
}

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return [[self allShipments] count];
}

- (Shipment *)shipmentAtIndexPath:(NSIndexPath *)indexPath {
    return [self allShipments][indexPath.row];
}

- (void)fetchNext {
    if (self.currentPage + 1 < [self.pagedShipments count]) {
        self.currentPage += 1;
        self.callback(nil);
    }
    else if (self.nextParameters) {
        NSMutableDictionary *parameters = [self.baseParameters mutableCopy];
        [parameters addEntriesFromDictionary:self.nextParameters];
        [self performFetchWithParameters:parameters callback:self.callback];
    }
}

- (void)fetchPrevious {
    self.currentPage -= 1;
    self.callback(nil);
}

- (void)fetchMoreWithCompletion:(TRControllerCallback)completion {
    NSMutableDictionary *parameters = [self.baseParameters mutableCopy];
    [parameters addEntriesFromDictionary:self.nextParameters];
    [self performFetchWithParameters:parameters callback:completion];
}

- (NSArray *)currentShipments {
    if (self.currentPage < 0) {
        return nil;
    }
    return self.pagedShipments[self.currentPage];
}

- (NSArray *)currentAnnotations {
    NSArray *shipments = [self currentShipments];
    if (shipments == nil) {
        return nil;
    }
    NSMutableArray *shipmentAnnotations = [NSMutableArray arrayWithCapacity:[shipments count]];
    for (Shipment *shipment in shipments) {
        ShipmentAnnotation *annotation = [[ShipmentAnnotation alloc] initWithShipment:shipment];
        [shipmentAnnotations addObject:annotation];
    }
    return [NSArray arrayWithArray:shipmentAnnotations];
}


#pragma mark - Private Property Overrides

- (NSDictionary *)baseParameters {
//    if (_baseParameters == nil) {
//        _baseParameters = [[AvailableShipmentSearchParameters sharedInstance] toQueryParameters];
//    }
//    return _baseParameters;
    return [[AvailableShipmentSearchParameters sharedInstance] toQueryParameters];
}


#pragma mark - Private Instance Methods

- (NSArray *)allShipments {
    return [self.pagedShipments valueForKeyPath:@"@unionOfArrays.self"];
}

- (void)performFetchWithParameters:parameters
						  callback:(TRControllerCallback)callback {
    [[APISessionManager sharedManager] openShipmentsWithParameters:parameters
                                                           success:[self successBlockWithCallback:callback]
                                                           failure:[self failureBlockWithCallback:callback]];
}

- (APISessionSuccessBlock)successBlockWithCallback:(TRControllerCallback)callback {
    return ^(NSURLSessionDataTask *task, id responseObject) {
        NSError *error;
        NSMutableDictionary *mutJSONDictionary = [(NSDictionary *)responseObject mutableCopy];
        [mutJSONDictionary removeObjectsForKeys:[mutJSONDictionary allKeysForObject:[NSNull null]]];
        NSUInteger count = [mutJSONDictionary[@"count"] integerValue];
        if (count != 0) {
            self.nextParameters = [self parseURLParameters:[NSURL URLWithString:mutJSONDictionary[@"next"]]];
            NSArray *results = mutJSONDictionary[@"results"];
            NSArray *shipments = [MTLJSONAdapter modelsOfClass:[Shipment class] fromJSONArray:results error:&error];
            
            if (shipments) {
                [self.pagedShipments addObject:shipments];
                self.currentPage += 1;
            }
        }
        if (callback) {
            callback(error);
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

- (NSDictionary *)parseURLParameters:(NSURL *)url {
    if (url == nil) {
        return nil;
    }
    NSString *queryString = [url query];
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionary];
    for (NSString *kvPairString in queryComponents) {
        NSArray *kvPairArray = [kvPairString componentsSeparatedByString:@"="];
        NSString *key = [[kvPairArray firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[kvPairArray lastObject] stringByRemovingPercentEncoding];
        [queryDictionary setObject:value forKey:key];
    }
    [queryDictionary removeObjectsForKeys:[self.baseParameters allKeys]];
    return [NSDictionary dictionaryWithDictionary:queryDictionary];
}

@end
