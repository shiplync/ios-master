//
//  Shipment.h
//  Impaqd
//
//  Created by Greg Nicholas on 2/8/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"
//#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "Location.h"
#import "DeliveryStatus.h"
#import "PayoutInfo.h"
#import "EquipmentTag.h"

typedef NS_ENUM(NSInteger, ShipmentStatus) {
    ShipmentStatusUnknown = 0,
    ShipmentStatusOpen,
    ShipmentStatusPendingPickup,
    ShipmentStatusPendingDelivery,
    ShipmentStatusDelivered,
    ShipmentStatusPendingApproval,
};


@interface Shipment : TRMTLModel

@property (nonatomic) DeliveryStatus *deliveryStatus;
@property (nonatomic) PayoutInfo *payoutInfo;
@property (nonatomic, readonly) NSArray *locations;
@property (nonatomic, readonly) NSArray *equipmentTags;
@property (nonatomic, readonly) NSNumber *traansmissionId;
@property (nonatomic, readonly) NSString *shipmentId;
@property (nonatomic, readonly) NSNumber *shipperId;
@property (nonatomic, readonly) NSString *shipperName;
@property (nonatomic, readonly) NBPhoneNumber *shipperPhoneNumber;
@property (nonatomic, readonly) NSString *receiverName;
@property (nonatomic, readonly) NBPhoneNumber *receiverPhoneNumber;
@property (nonatomic, readonly) NSNumber *tripDistance;
@property (nonatomic, readonly) NSString *bolNumber;
- (NSString*)convertedTripDistance;
- (NSString*)formattedTripDistance;
- (NSDictionary*)formattedEquipmentTags;

@property (nonatomic, readonly) NSString *pickUpAddress;
@property (nonatomic) NSNumber *pickUpLongitude;
@property (nonatomic) NSNumber *pickUpLatitude;
@property (nonatomic) NSDate *pickUpTimeRangeStart;
@property (nonatomic) NSDate *pickUpTimeRangeEnd;
@property (nonatomic) NSTimeZone *pickUpTimeZone;
@property (nonatomic, readonly) NSString *pickUpDock;

@property (nonatomic, readonly) NSString *deliveryAddress;
@property (nonatomic) NSNumber *deliveryLongitude;
@property (nonatomic) NSNumber *deliveryLatitude;
@property (nonatomic) NSDate *deliveryTimeRangeStart;
@property (nonatomic) NSDate *deliveryTimeRangeEnd;
@property (nonatomic) NSTimeZone *deliveryTimeZone;
@property (nonatomic, readonly) NSString *deliveryDock;

@property (nonatomic, readonly) NSNumber *weight;
@property (nonatomic, readonly) NSNumber *palletized;
@property (nonatomic, readonly) NSNumber *pallet_height;
@property (nonatomic, readonly) NSNumber *pallet_length;
@property (nonatomic, readonly) NSNumber *pallet_width;
@property (nonatomic, readonly) NSNumber *pallet_number;

@property (nonatomic) NSDecimalNumber *payoutUSD;
@property (nonatomic) NSString *payoutUSDtext;
@property (nonatomic, readonly) NSNumber *payout_mile;
@property (nonatomic, readonly) NSString *extraDetails;
@property (nonatomic, readonly) VehicleType vehicleType;
@property (nonatomic, readonly) NSDecimalNumber *tripDistanceMiles;

//@property (nonatomic) NSNumber *deliveryStatus;
@property (nonatomic, readonly) NSNumber *carrierId;
@property (nonatomic, readonly) BOOL carrierIsApproved;
@property (nonatomic) NSDate *pickedUpAt;
@property (nonatomic) NSDate *deliveredAt;


#pragma mark - Derived Properties

- (NSString *)serverId DEPRECATED_ATTRIBUTE;
- (NSString *)shipperPhone DEPRECATED_ATTRIBUTE;
- (NSString *)receiverPhone DEPRECATED_ATTRIBUTE;
- (NSTimeZone *)pickupTz DEPRECATED_ATTRIBUTE;
- (NSTimeZone *)deliveryTz DEPRECATED_ATTRIBUTE;

@property (nonatomic, readonly) CLLocationCoordinate2D pickUpCoordinate;
@property (nonatomic, readonly) CLLocationCoordinate2D deliveryCoordinate;
@property (nonatomic) BOOL palletizedValue;

@property (nonatomic, readonly) TRDateRange *pickUpDateRange;
@property (nonatomic, readonly) TRDateRange *deliveryDateRange;

#pragma mark - Dynamic Properties

@property (nonatomic, copy, readonly) NSString *pickUpAddressMinimum;
@property (nonatomic, copy, readonly) NSString *deliveryAddressMinimum;
@property (nonatomic, copy, readonly) NSString *deliveryStatusDescription DEPRECATED_ATTRIBUTE;
@property (nonatomic, assign, readonly) BOOL deliveryApproved;
@property (nonatomic, copy, readonly) NSString *pickUpTimeDescription;
@property (nonatomic, copy, readonly) NSString *deliveryTimeDescription;
@property (nonatomic, copy, readonly) NSString *payoutDescription;
@property (nonatomic, copy, readonly) NSString *pickUpDistanceDescription;
@property (nonatomic, copy, readonly) NSString *deliveryDistanceDescription;
@property (nonatomic, copy, readonly) NSString *payoutPerMileDescription;
@property (nonatomic, copy, readonly) NSString *weightDescription;
@property (nonatomic, copy, readonly) NSString *palletDescription;
@property (nonatomic, copy, readonly) NSString *vehicleTypeDescription;

/**
 *  Initialize a Shipment object from a dictionary of attributes (as returned by the API).
 *
 *  @param attrs NSDictionary
 */
- (instancetype)initWithJSONAttributes:(NSDictionary *)attrs DEPRECATED_ATTRIBUTE;

extern NSString * const ShipmentFetchErrorDomain;
typedef NS_ENUM(NSUInteger, ShipmentFetchErrorCode) {
    ShipmentFetchErrorCodeInvalidResponse,
    ShipmentFetchErrorCodeNetworkError
};

@end
