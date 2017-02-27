//
//  OHHTTPStubsHelper.m
//  Impaqd
//
//  Created by Traansmission on 5/5/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "OHHTTPStubsHelper.h"

@implementation OHHTTPStubsHelper

+ (instancetype)sharedInstance {
    static OHHTTPStubsHelper *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[OHHTTPStubsHelper alloc] init];
    });
    return __sharedInstance;
}

#pragma mark - Public Instance Methods

- (void)setUpStubs {
}

- (void)tearDownStubs {
    [OHHTTPStubs removeAllStubs];
}

- (void)setUpLoginSuccessStubs {
    [self loginSuccessStub];
    [self carriersSingleStub];
    [self usersSelfStub];
}

- (void)setUpOpenShipmentsStubs {
    [self openShipmentsStub];
    [self shipmentOneStub];
}


#pragma mark - Private Instance Methods

- (void)loginSuccessStub {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURL *url = [request URL];
        BOOL hostMatch = [[url host] isEqualToString:@"api.traansmission.com"];
        BOOL urlMatch = [[url path] isEqualToString:@"/api/login"];
        
        return hostMatch && urlMatch;
    }
    withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSDictionary *jsonDict = @{ @"token" : @"1234567890",
                                    @"type" : @"carrier" };
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
        return [OHHTTPStubsResponse responseWithData:jsonData statusCode:200 headers:@{ @"content-type" : @"application/json" }];
    }];
}

- (void)carriersSingleStub DEPRECATED_ATTRIBUTE {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURL *url = [request URL];
        BOOL hostMatch = [[url host] isEqualToString:@"api.traansmission.com"];
        BOOL urlMatch = [[url path] isEqualToString:@"/api/carriers/single"];
        
        return hostMatch && urlMatch;
    }
    withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSString *carrierJSONPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"carriers_single" ofType:@"json"];
        return [OHHTTPStubsResponse responseWithFileAtPath:carrierJSONPath statusCode:200 headers:@{ @"content-type" : @"application/json" }];
    }];
}

- (void)usersSelfStub {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURL *url = [request URL];
        BOOL hostMatch = [[url host] isEqualToString:@"api.traansmission.com"];
        BOOL urlMatch = [[url path] isEqualToString:@"/api/carriers/self/drivers"];
        BOOL queryMatch = [[url query] isEqualToString:@"nested=true"];
        
        return hostMatch && urlMatch && queryMatch;
    }
    withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSString *carrierJSONPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"carriers_self_drivers_nested" ofType:@"json"];
        return [OHHTTPStubsResponse responseWithFileAtPath:carrierJSONPath statusCode:200 headers:@{ @"content-type" : @"application/json" }];
    }];
}

- (void)openShipmentsStub {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURL *url = [request URL];
        BOOL methodMatch = [[request HTTPMethod] isEqualToString:@"GET"];
        BOOL hostMatch = [[url host] isEqualToString:@"api.traansmission.com"];
        BOOL urlMatch = [[url path] isEqualToString:@"/api/shipments"];
        return methodMatch && hostMatch && urlMatch;
    }
    withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSString *openShipmentsPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"paged_shipments" ofType:@"json"];
        return [OHHTTPStubsResponse responseWithFileAtPath:openShipmentsPath statusCode:200 headers:@{ @"content-type" : @"application/json" }];
        
    }];
}

- (void)shipmentOneStub {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSURL *url = [request URL];
        BOOL methodMatch = [[request HTTPMethod] isEqualToString:@"GET"];
        BOOL hostMatch = [[url host] isEqualToString:@"api.traansmission.com"];
        BOOL urlMatch = [[url path] isEqualToString:@"/api/shipments/1"];
        return methodMatch && hostMatch && urlMatch;
    }
    withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSString *openShipmentsPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"shipment_1" ofType:@"json"];
        return [OHHTTPStubsResponse responseWithFileAtPath:openShipmentsPath statusCode:200 headers:@{ @"content-type" : @"application/json" }];
    }];
}

@end
