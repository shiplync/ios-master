//
//  APISessionManager.m
//  Impaqd
//
//  Created by Traansmission on 4/8/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "APISessionManager.h"
#import "TraansmissionKit.h"
#import "constants.h"
#import "TRJSONResponseSerializer.h"
#import <SSKeychain/SSKeychain.h>
#import "sharedConstants.h"
#import "Shipment.h"
#import "LocationCoordinator.h"
#import "AFHTTPSessionManager.h"

@interface APISessionManager ()

@property (nonatomic) AFJSONRequestSerializer *unauthorizedRequestSerializer;
@property (nonatomic) AFJSONRequestSerializer *authorizedRequestSerializer;
@property (nonatomic) AFJSONRequestSerializer *geoAuthorizedRequestSerializer;

@end

@implementation APISessionManager

+ (instancetype)sharedManager {
    static APISessionManager *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:kBaseURL];
        __sharedInstance = [[APISessionManager alloc] initWithBaseURL:baseURL];
    });
    return __sharedInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.requestSerializer = self.unauthorizedRequestSerializer;;
        self.responseSerializer = [[TRJSONResponseSerializer alloc] init];
    }
    return self;
}

- (APISessionSuccessBlock)successBlockWithCompletion:(APISessionSuccessBlock)completion {
    return ^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            completion(task, responseObject);
        }
    };
}

- (APISessionFailureBlock)failureBlockWithCompletion:(APISessionFailureBlock)completion {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        if ([error.domain isEqualToString:NSURLErrorDomain]) {
            if (error.code == NSURLErrorTimedOut) {
                error = [NSError URLCannotConnectToHostWithAttempter:nil];
            }
        }
        else if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain]) {
            NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            if (response.statusCode == 401 && error.code == NSURLErrorBadServerResponse) {
                error = [NSError errorWithDomain:TRErrorDomain code:NSURLErrorUserAuthenticationRequired userInfo:nil];
            }
            else if (response.statusCode == 500) {
                error = [NSError serverError];
            }
        }
        if (completion) {
            completion(task, error);
        }
    };
}

- (NSURL *)termsOfServiceURL {
    return [NSURL URLWithString:@"http://traansmission.com/#/terms-of-service?raw=1"];
}

- (NSURL *)privacyPolicyURL {
    return [NSURL URLWithString:@"http://traansmission.com/#/privacy-policy?raw=1"];
}


- (void)checkVersion:(NSString *)version
          parameters:(NSDictionary *)parameters
             success:(APISessionSuccessBlock)success
             failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.unauthorizedRequestSerializer;
    NSString *url = [NSString stringWithFormat:@"check_version/%@/", version];
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self GET:url parameters:parameters success:_success failure:_failure];
}

- (void)verifyTokenWithParameters:(NSDictionary *)parameters
                          success:(APISessionSuccessBlock)success
                          failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.authorizedRequestSerializer;
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self GET:@"verify_token/" parameters:parameters success:_success failure:_failure];
}

- (void)loginWithParameters:(NSDictionary *)parameters
                    success:(APISessionSuccessBlock)success
                    failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.unauthorizedRequestSerializer;
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self POST:@"login/" parameters:parameters success:_success failure:_failure];
}


- (void)carriersRegisterWithParameters:(NSDictionary *)parameters
                               success:(APISessionSuccessBlock)success
                               failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.unauthorizedRequestSerializer;
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self POST:@"carriers/register/" parameters:parameters success:_success failure:_failure];
}

- (void)carriersStatusWithParameters:(NSDictionary *)parameters
                             success:(APISessionSuccessBlock)success
                             failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.authorizedRequestSerializer;
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self GET:@"carriers/status/" parameters:parameters success:_success failure:_failure];
}

- (void)patchCarriersSingleWithParameters:(NSDictionary *)parameters
                                  success:(APISessionSuccessBlock)success
                                  failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.authorizedRequestSerializer;
    
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self PATCH:@"carriers/single/" parameters:parameters success:_success failure:_failure];
}

- (void)usersSelfParameters:(NSDictionary *)parameters
                                    success:(APISessionSuccessBlock)success
                                    failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.authorizedRequestSerializer;
    
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self GET:@"users/self/" parameters:parameters success:_success failure:_failure];
}

- (void)patchUsersSelfParameters:(NSDictionary *)parameters
                                         success:(APISessionSuccessBlock)success
                                         failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.authorizedRequestSerializer;
    
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self PATCH:@"users/self/" parameters:parameters success:_success failure:_failure];
}

- (void)carrierShipmentsWithParameters:(NSDictionary *)parameters
                               success:(APISessionSuccessBlock)success
                               failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.authorizedRequestSerializer;
    
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self GET:@"carriers/shipments/" parameters:parameters success:_success failure:_failure];
}

- (void)carriersShipmentsTempWithParameters:(NSDictionary *)parameters
                                    success:(APISessionSuccessBlock)success
                                    failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.authorizedRequestSerializer;
    
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self GET:@"shipments/?paginate_by=100" parameters:parameters success:_success failure:_failure];
}

- (void)patchShipment:(Shipment *)shipment
           parameters:(NSDictionary *)parameters
              success:(APISessionSuccessBlock)success
              failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.authorizedRequestSerializer;
    
    NSString *url = [NSString stringWithFormat:@"carriers/shipments/%@/", shipment.traansmissionId];
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self PATCH:url parameters:parameters success:_success failure:_failure];
}

- (void)postAcceptTOSWithParameters:(NSDictionary *)parameters
                            success:(APISessionSuccessBlock)success
                            failure:(APISessionFailureBlock)failure
{
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.authorizedRequestSerializer;
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self POST:@"tos/" parameters:parameters success:_success failure:_failure];
}

- (void)postFile:(NSData *)fileData
      parameters:(NSDictionary *)parameters
         success:(APISessionSuccessBlock)success
         failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.authorizedRequestSerializer;
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self POST:@"files/?path=profile_photo" parameters:parameters
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileData:fileData name:@"file" fileName:@"profilePhoto.png" mimeType:@"image/png"];
}
       success:_success failure:_failure];
}

- (void)postGeoLocation:(CLLocation *)location
             parameters:(NSDictionary *)parameters
                success:(APISessionSuccessBlock)success
                failure:(APISessionFailureBlock)failure {
    //Do not access reachabilitymanager here. Won't work in background mode.
    self.requestSerializer = self.authorizedRequestSerializer;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ'";
    NSDictionary *geoParameters = @{ @"latitude"  : [NSNumber numberWithDouble:location.coordinate.latitude],
                                     @"longitude" : [NSNumber numberWithDouble:location.coordinate.longitude],
                                     @"altitude"  : [NSNumber numberWithDouble:location.altitude],
                                     @"accuracy"  : [NSNumber numberWithDouble:location.horizontalAccuracy],
                                     @"speed"     : [NSNumber numberWithDouble:location.speed],
                                     @"course"    : [NSNumber numberWithDouble:location.course],
                                     @"timestamp" : [dateFormatter stringFromDate:location.timestamp] };
    
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self POST:@"geolocations/" parameters:geoParameters success:_success failure:_failure];
}

- (void)openShipmentsWithParameters:(NSDictionary *)parameters
                            success:(APISessionSuccessBlock)success
                            failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.geoAuthorizedRequestSerializer;
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self GET:@"shipments/" parameters:parameters success:_success failure:_failure];
}

- (void)shipmentWithId:(NSNumber *)traansmissionId
            parameters:(NSDictionary *)parameters
               success:(APISessionSuccessBlock)success
               failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.authorizedRequestSerializer;
    NSString *path = [NSString stringWithFormat:@"shipments/?id=%@", traansmissionId];
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self GET:path parameters:parameters success:_success failure:_failure];
}

- (void)claimShipmentWithId:(NSNumber *)traansmissionId
                 parameters:(NSDictionary *)parameters
                    success:(APISessionSuccessBlock)success
                    failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
    self.requestSerializer = self.authorizedRequestSerializer;
    NSString *path = [NSString stringWithFormat:@"carriers/shipments/%@/", traansmissionId];
    NSMutableDictionary *params = [@{ @"carrier_set_self": @YES } mutableCopy];
    [params addEntriesFromDictionary:parameters];
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self PATCH:path parameters:params success:_success failure:_failure];
}

- (void)resetAuthenticatedRequestSerializer {
    _authorizedRequestSerializer = nil;
    _geoAuthorizedRequestSerializer = nil;
}

#pragma mark - Private Property Overrides

- (AFJSONRequestSerializer *)unauthorizedRequestSerializer {
    if (_unauthorizedRequestSerializer == nil) {
        _unauthorizedRequestSerializer = [[AFJSONRequestSerializer alloc] init];
    }
    return _unauthorizedRequestSerializer;
}

- (AFJSONRequestSerializer *)authorizedRequestSerializer {
    if (_authorizedRequestSerializer == nil) {
        NSString* token = [SSKeychain passwordForService:TOKEN_LOGIN account:DEFAULT_ACCOUNT];
        if (token) {
            _authorizedRequestSerializer = [[AFJSONRequestSerializer alloc] init];
            [_authorizedRequestSerializer setValue:[NSString stringWithFormat:@"Token %@",token] forHTTPHeaderField:@"Authorization"];
        }
    }
    return _authorizedRequestSerializer;
}

- (AFJSONRequestSerializer *)geoAuthorizedRequestSerializer {
    if (_geoAuthorizedRequestSerializer == nil) {
        NSString* token = [SSKeychain passwordForService:TOKEN_LOGIN account:DEFAULT_ACCOUNT];
        if (token) {
            _geoAuthorizedRequestSerializer = [[AFJSONRequestSerializer alloc] init];
            [_geoAuthorizedRequestSerializer setValue:[NSString stringWithFormat:@"Token %@",token] forHTTPHeaderField:@"Authorization"];
        }
    }
    //Use last know location instead of retrieving a new location everytime
    //user refreshes map.
    CLLocation *location = [[LocationCoordinator sharedInstance] lastLocation];
    if (location) {
        CLLocationCoordinate2D coordinate = location.coordinate;
        [_geoAuthorizedRequestSerializer setValue:[NSString stringWithFormat:@"geo:%.6f,%.6f", coordinate.longitude, coordinate.latitude]
                               forHTTPHeaderField:@"Geolocation"];
    }
    return _geoAuthorizedRequestSerializer;
}

- (void)registerDeviceToken:(NSString *)token
				 parameters:(NSDictionary *)parameters
                    success:(APISessionSuccessBlock)success
                    failure:(APISessionFailureBlock)failure {
    if (![[self reachabilityManager] isReachable]) {
        if (failure) {
            failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
        }
        return;
    }
	
    self.requestSerializer = self.authorizedRequestSerializer;
    NSDictionary *params = @{ @"identifier"  : token, @"platform_type": [NSNumber numberWithInteger:2]};
    APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
    APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
    [self POST:@"platforms/" parameters:params success:_success failure:_failure];
}

- (void)getPlatformIdWithToken:(NSString *)token
			parameters:(NSDictionary *)parameters
			   success:(APISessionSuccessBlock)success
			   failure:(APISessionFailureBlock)failure {
	
	if (![[self reachabilityManager] isReachable]) {
		if (failure) {
			failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
		}
		return;
	}
	
	self.requestSerializer = self.authorizedRequestSerializer;
	NSString *path = [NSString stringWithFormat:@"platforms/?identifier=%@", token];
	APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
	APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
	[self GET:path parameters:parameters success:_success failure:_failure];
}

- (void)removeDeviceTokenWithId:(NSString *)platform_id
					 parameters:(NSDictionary *)parameters
						success:(APISessionSuccessBlock)success
						failure:(APISessionFailureBlock)failure {
	if (![[self reachabilityManager] isReachable]) {
		if (failure) {
			failure(nil, [NSError URLCannotConnectToHostWithAttempter:nil]);
		}
		return;
	}
	
	self.requestSerializer = self.authorizedRequestSerializer;
	NSString *path = [NSString stringWithFormat:@"platforms/%@/", platform_id];
	APISessionSuccessBlock _success = [self successBlockWithCompletion:success];
	APISessionFailureBlock _failure = [self failureBlockWithCompletion:failure];
	[self DELETE:path parameters:parameters success:_success failure:_failure];
}





@end
