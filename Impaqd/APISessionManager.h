//
//  APISessionManager.h
//  Impaqd
//
//  Created by Traansmission on 4/8/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import <CoreLocation/CoreLocation.h>

typedef void (^APISessionSuccessBlock)(NSURLSessionDataTask *, id);
typedef void (^APISessionFailureBlock)(NSURLSessionDataTask *, NSError *);

@class Shipment;

@interface APISessionManager : AFHTTPSessionManager

+ (instancetype)sharedManager;

- (APISessionSuccessBlock)successBlockWithCompletion:(APISessionSuccessBlock)completion;
- (APISessionFailureBlock)failureBlockWithCompletion:(APISessionFailureBlock)completion;

- (NSURL *)termsOfServiceURL;
- (NSURL *)privacyPolicyURL;

- (void)checkVersion:(NSString *)version
          parameters:(NSDictionary *)parameters
             success:(APISessionSuccessBlock)success
             failure:(APISessionFailureBlock)failure;

- (void)verifyTokenWithParameters:(NSDictionary *)parameters
                          success:(APISessionSuccessBlock)success
                          failure:(APISessionFailureBlock)failure;

- (void)carriersRegisterWithParameters:(NSDictionary *)parameters
                              success:(APISessionSuccessBlock)success
                              failure:(APISessionFailureBlock)failure;

- (void)carriersStatusWithParameters:(NSDictionary *)parameters
                             success:(APISessionSuccessBlock)success
                             failure:(APISessionFailureBlock)failure;

- (void)loginWithParameters:(NSDictionary *)parameters
                    success:(APISessionSuccessBlock)success
                    failure:(APISessionFailureBlock)failure;

- (void)patchCarriersSingleWithParameters:(NSDictionary *)parameters
                                  success:(APISessionSuccessBlock)success
                                  failure:(APISessionFailureBlock)failure DEPRECATED_ATTRIBUTE;

- (void)usersSelfParameters:(NSDictionary *)parameters
                                    success:(APISessionSuccessBlock)success
                                    failure:(APISessionFailureBlock)failure;

- (void)patchUsersSelfParameters:(NSDictionary *)parameters
                                         success:(APISessionSuccessBlock)success
                                         failure:(APISessionFailureBlock)failure;

- (void)carrierShipmentsWithParameters:(NSDictionary *)parameters
                               success:(APISessionSuccessBlock)success
                               failure:(APISessionFailureBlock)failure  DEPRECATED_ATTRIBUTE;

- (void)carriersShipmentsTempWithParameters:(NSDictionary *)parameters
                                    success:(APISessionSuccessBlock)success
                                    failure:(APISessionFailureBlock)failure;

- (void)patchShipment:(Shipment *)shipment
           parameters:(NSDictionary *)parameters
              success:(APISessionSuccessBlock)success
              failure:(APISessionFailureBlock)failure DEPRECATED_ATTRIBUTE;

- (void)postAcceptTOSWithParameters:(NSDictionary *)parameters
                            success:(APISessionSuccessBlock)success
                            failure:(APISessionFailureBlock)failure;

- (void)postFile:(NSData *)fileData
      parameters:(NSDictionary *)parameters
         success:(APISessionSuccessBlock)success
         failure:(APISessionFailureBlock)failure;

- (void)postGeoLocation:(CLLocation *)location
             parameters:(NSDictionary *)parameters
                success:(APISessionSuccessBlock)success
                failure:(APISessionFailureBlock)failure;

- (void)openShipmentsWithParameters:(NSDictionary *)parameters
                            success:(APISessionSuccessBlock)success
                            failure:(APISessionFailureBlock)failure;

- (void)shipmentWithId:(NSNumber *)traansmissionId
            parameters:(NSDictionary *)parameters
               success:(APISessionSuccessBlock)success
               failure:(APISessionFailureBlock)failure;

- (void)claimShipmentWithId:(NSNumber *)traansmissionId
                 parameters:(NSDictionary *)parameters
                    success:(APISessionSuccessBlock)success
                    failure:(APISessionFailureBlock)failure;

- (void)resetAuthenticatedRequestSerializer;

- (void)registerDeviceToken:(NSString *)token
				 parameters:(NSDictionary *)parameters
                    success:(APISessionSuccessBlock)success
                    failure:(APISessionFailureBlock)failure;

- (void)getPlatformIdWithToken:(NSString *)token
					parameters:(NSDictionary *)parameters
					   success:(APISessionSuccessBlock)success
					   failure:(APISessionFailureBlock)failure;

- (void)removeDeviceTokenWithId:(NSString *)platform_id
					 parameters:(NSDictionary *)parameters
						success:(APISessionSuccessBlock)success
						failure:(APISessionFailureBlock)failure;


@end
