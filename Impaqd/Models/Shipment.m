//
//  Shipment.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/8/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "Shipment.h"
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "HelperFunctions.h"
#import "LocationCoordinator.h"
#import <MapKit/MapKit.h>

NSString * const ShipmentFetchErrorDomain = @"ShipmentFetchErrorDomain";

@interface Shipment ()

@property (nonatomic, readwrite) CLLocationCoordinate2D pickUpCoordinate;
@property (nonatomic, readwrite) CLLocationCoordinate2D deliveryCoordinate;

@end

@implementation Shipment

#pragma mark - Mantle Class Method Overrides

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"traansmissionId"        : @"id",
              @"shipmentId"             : @"id",
              @"locations"              : @"locations",
              @"equipmentTags"          : @"equipmenttags",
              @"deliveryStatus"         : @"delivery_status",
              @"tripDistance"           : @"trip_distance",
              @"payoutInfo"             : @"payout_info",
              @"bolNumber"              : @"bol_number",
              //              @"shipperId"              : @"shipper",
              //              @"shipperName"            : @"shipper_name",
              //              @"shipperPhoneNumber"     : @"shipper_phone",
              //              @"receiverName"           : @"receiver_name",
              //              @"receiverPhoneNumber"    : @"receiver_phone",
              //
              //              @"pickUpAddress"          : @"pick_up_address",
              //              @"pickUpLongitude"        : @"pick_up_longitude",
              //              @"pickUpLatitude"         : @"pick_up_latitude",
              //              @"pickUpTimeRangeStart"   : @"pick_up_time_range_start",
              //              @"pickUpTimeRangeEnd"     : @"pick_up_time_range_end",
              //              @"pickUpTimeZone"         : @"pick_up_tz",
              //              @"pickUpDock"             : @"pick_up_dock",
              //
              //              @"deliveryAddress"        : @"delivery_address",
              //              @"deliveryLatitude"       : @"delivery_latitude",
              //              @"deliveryLongitude"      : @"delivery_longitude",
              //              @"deliveryTimeRangeStart" : @"delivery_time_range_start",
              //              @"deliveryTimeRangeEnd"   : @"delivery_time_range_end",
              //              @"deliveryTimeZone"       : @"delivery_tz",
              //              @"deliveryDock"           : @"delivery_dock",
              //
              //              @"weight"                 : @"weight",
              //              @"palletized"             : @"palletized",
              //              @"pallet_height"          : @"pallet_height",
              //              @"pallet_length"          : @"pallet_length",
              //              @"pallet_width"           : @"pallet_width",
              //              @"pallet_number"          : @"pallet_number",
              //
              //              @"payoutUSD"              : @"payout",
              //              @"payoutUSDtext"          : @"payout_text",
              //              @"payout_mile"            : @"payout_mile",
              //              @"extraDetails"           : @"extra_details",
              //              @"vehicleType"            : @"vehicle_type",
              //              @"tripDistanceMiles"      : @"trip_distance_miles",
              //
              //              @"deliveryStatus"         : @"delivery_status",
              //              @"carrierId"              : @"carrier",
              //              @"carrierIsApproved"      : @"carrier_is_approved",
              //              @"pickedUpAt"             : @"picked_up_at",
              //              @"deliveredAt"            : @"delivered_at"
              };
}

+ (NSValueTransformer *)deliveryStatusJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[DeliveryStatus class]];
}

+ (NSValueTransformer *)payoutInfoJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[PayoutInfo class]];
}

+ (NSValueTransformer *)locationsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[Location class]];
}

+ (NSValueTransformer *)equipmentTagsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[EquipmentTag class]];
}

- (NSNumber*)convertedTripDistance
{
    // Hard coded to return value in miles.
    // TODO: Make compatible with other lenght measures (km).
    if (self.tripDistance) {
        return [NSNumber numberWithDouble:self.tripDistance.doubleValue / 1609.344];
    } else {
        return nil;
    }
}

- (NSString*)formattedTripDistance
{
    if (self.tripDistance) {
        NSString *fmtString = [self convertedTripDistance].doubleValue > 10.0 ? @"%.0f miles" : @"%.1f miles";
        return [NSString stringWithFormat:fmtString, [self convertedTripDistance].floatValue];
    } else {
        return nil;
    }
}

- (NSDictionary*)formattedEquipmentTags
{
    if (self.equipmentTags.count) {
        NSMutableDictionary *categoryDict = [[NSMutableDictionary alloc] initWithDictionary:@{}];
        for (EquipmentTag *e in self.equipmentTags) {
            NSMutableArray *categoryItem = [categoryDict objectForKey:e.tagCategoryLabel];
            if (categoryItem) {
                [categoryItem addObject:e];
            } else {
                categoryItem = [[NSMutableArray alloc] initWithArray:@[e]];
                [categoryDict setObject:categoryItem forKey:e.tagCategoryLabel];
            }
        }
        return categoryDict;
    } else {
        return @{};
    }
}

//+ (NSValueTransformer *)shipperPhoneNumberJSONTransformer {
//    return [self PhoneNumberJSONTransformer];
//}
//
//+ (NSValueTransformer *)receiverPhoneNumberJSONTransformer {
//    return [self PhoneNumberJSONTransformer];
//}
//
//+ (NSValueTransformer *)pickUpTimeRangeStartJSONTransformer {
//    return [self NSDateJSONTransformer];
//}
//
//+ (NSValueTransformer *)pickUpTimeRangeEndJSONTransformer {
//    return [self NSDateJSONTransformer];
//}
//
//+ (NSValueTransformer *)pickUpTimeZoneJSONTransformer {
//    return [self NSTimeZoneJSONTransformer];
//}
//
//+ (NSValueTransformer *)deliveryTimeRangeStartJSONTransformer {
//    return [self NSDateJSONTransformer];
//}
//
//+ (NSValueTransformer *)deliveryTimeRangeEndJSONTransformer {
//    return [self NSDateJSONTransformer];
//}
//
//+ (NSValueTransformer *)deliveryTimeZoneJSONTransformer {
//    return [self NSTimeZoneJSONTransformer];
//}
//
//+ (NSValueTransformer *)pickedUpAtJSONTransformer {
//    return [self NSDateJSONTransformer];
//}
//
//+ (NSValueTransformer *)deliveredAtJSONTransformer {
//    return [self NSDateJSONTransformer];
//}
//
//+ (NSValueTransformer *)extraDetailsJSONTransformer {
//    return [MTLValueTransformer
//            transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
//                *success = YES;
//                *error = nil;
//                return ([(NSString *)value length] > 0) ? value : nil;
//            }
//            reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
//                *success = YES;
//                *error = nil;
//                return value;
//            }];
//}
//
//+ (NSValueTransformer *)payoutUSDJSONTransformer {
//    return [MTLValueTransformer
//            transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
//                *success = YES;
//                *error = nil;
//                if ([value isKindOfClass:[NSString class]]) {
//                    return [NSDecimalNumber numberWithDouble:[(NSString *)value doubleValue]];
//                }
//                else {
//                    return value;
//                }
//            }
//            reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
//                *success = YES;
//                *error = nil;
//                return value;
//            }];
//}


#pragma mark - KVO KeyPaths for Dynamic Properties

//+ (NSSet *)keyPathsForValuesAffectingPickUpDateRange {
//    return [NSSet setWithObjects:NSStringFromSelector(@selector(pickUpTimeRangeStart)), NSStringFromSelector(@selector(pickUpTimeRangeEnd)), nil];
//}
//
//+ (NSSet *)keyPathsForValuesAffectingDeliveryDateRange {
//    return [NSSet setWithObjects:NSStringFromSelector(@selector(deliveryTimeRangeStart)), NSStringFromSelector(@selector(deliveryTimeRangeEnd)), nil];
//}


#pragma mark - Object Lifecycle

- (instancetype)initWithJSONAttributes:(NSDictionary *)attrs
{
    self = [super init];
    if (self) {
        NSDictionary *jsonDict = [self stripNullsFromDictionary:attrs];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [formatter setLocale:posix];
        
        _traansmissionId = jsonDict[@"id"];
        //        _shipmentId = [jsonDict[@"shipment_id"] copy];
        //        _shipperId = jsonDict[@"shipper"];
        //        _shipperName = [jsonDict[@"shipper_name"] copy];
        //        _shipperPhoneNumber = [[TRPhoneNumberFormatter defaultFormatter] phoneNumberFromString:jsonDict[@"shipper_phone"]];
        //        _receiverName = [jsonDict[@"receiver_name"] copy];
        //        _shipperPhoneNumber = [[TRPhoneNumberFormatter defaultFormatter] phoneNumberFromString:jsonDict[@"receiver_phone"]];
        //
        //        _pickUpAddress = jsonDict[@"pick_up_address"];
        //        _pickUpLatitude = jsonDict[@"pick_up_latitude"];
        //        _pickUpLongitude = jsonDict[@"pick_up_longitude"];
        //        _pickUpTimeRangeStart = [formatter dateFromString:jsonDict[@"pick_up_time_range_start"]];
        //        _pickUpTimeRangeEnd = [formatter dateFromString:jsonDict[@"pick_up_time_range_end"]];
        //        _pickUpTimeZone = [NSTimeZone timeZoneWithName:jsonDict[@"pick_up_tz"]];
        //        _pickUpDock = jsonDict[@"pick_up_dock"];
        //
        //        _deliveryAddress = jsonDict[@"delivery_address"];
        //        _deliveryLatitude = jsonDict[@"delivery_latitude"];
        //        _deliveryLongitude = jsonDict[@"delivery_longitude"];
        //
        //        _deliveryDock = jsonDict[@"delivery_dock"];
        //        _deliveryTimeRangeStart = [formatter dateFromString:jsonDict[@"delivery_time_range_start"]];
        //        _deliveryTimeRangeEnd = [formatter dateFromString:jsonDict[@"delivery_time_range_end"]];
        //        _deliveryTimeZone = [NSTimeZone timeZoneWithName:jsonDict[@"delivery_tz"]];
        //
        //        [self parseWeightAndPalletJSON:jsonDict];
        //        [self parsePayoutJSON:jsonDict];
        //
        //        if (jsonDict[@"extra_details"] != [NSNull null] && jsonDict[@"extra_details"] != nil){
        //            NSString* extraDetails = [jsonDict[@"extra_details"] copy];
        //            extraDetails = [[extraDetails componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
        //            _extraDetails = extraDetails;
        //        }
        //
        //        NSNumber *vehicleTypeNumber = jsonDict[@"vehicle_type"];
        //        _vehicleType = VehicleTypeFromNSNumber(vehicleTypeNumber);
        //        _tripDistanceMiles = jsonDict[@"trip_distance_miles"];
        //
        //        _deliveryStatus = jsonDict[@"delivery_status"];
        //        _carrierId = jsonDict[@"carrier"];
        //        _carrierIsApproved = [jsonDict[@"carrier_is_approved"] boolValue];
        //
        //        if (jsonDict[@"picked_up_at"] != [NSNull null] && jsonDict[@"picked_up_at"] != nil) {
        //            _pickedUpAt = [formatter dateFromString:jsonDict[@"picked_up_at"]];
        //        }
        //
        //        if (jsonDict[@"delivered_at"] != [NSNull null] && jsonDict[@"delivered_at"] != nil) {
        //            _deliveredAt = [formatter dateFromString:jsonDict[@"delivered_at"]];
        //        }
        //
        //        self.pickUpCoordinate = CLLocationCoordinate2DMake([self.pickUpLatitude doubleValue], [self.pickUpLongitude doubleValue]);
        //        self.deliveryCoordinate = CLLocationCoordinate2DMake([self.deliveryLatitude doubleValue], [self.deliveryLongitude doubleValue]);
    }
    return self;
}


#pragma mark - Dynamic Property Overrides

- (NSString *)serverId {
    return [self.traansmissionId stringValue];
}

//- (NSString *)shipperPhone {
//    return [[TRPhoneNumberFormatter defaultFormatter] stringFromPhoneNumber:self.shipperPhoneNumber];
//}
//
//- (NSString *)receiverPhone {
//    return [[TRPhoneNumberFormatter defaultFormatter] stringFromPhoneNumber:self.receiverPhoneNumber];
//}
//
//- (NSTimeZone *)pickupTz {
//    return self.pickUpTimeZone;
//}
//
//- (NSTimeZone *)deliveryTz {
//    return self.deliveryTimeZone;
//}
//
//- (CLLocationCoordinate2D)pickUpCoordinate {
//    if (![self coordinateIsValid:(_pickUpCoordinate)]) {
//        _pickUpCoordinate = CLLocationCoordinate2DMake([self.pickUpLatitude doubleValue], [self.pickUpLongitude doubleValue]);
//    }
//    return _pickUpCoordinate;
//}
//
//- (CLLocationCoordinate2D)deliveryCoordinate {
//    if (![self coordinateIsValid:(_deliveryCoordinate)]) {
//        _deliveryCoordinate = CLLocationCoordinate2DMake([self.deliveryLatitude doubleValue], [self.deliveryLongitude doubleValue]);
//    }
//    return _deliveryCoordinate;
//}
//
//- (TRDateRange *)pickUpDateRange {
//    return [[TRDateRange alloc] initWithStart:self.pickUpTimeRangeStart end:self.pickUpTimeRangeEnd];
//}
//
//- (TRDateRange *)deliveryDateRange {
//    return [[TRDateRange alloc] initWithStart:self.deliveryTimeRangeStart end:self.deliveryTimeRangeEnd];
//}
//

#pragma mark -

//- (NSString *)pickUpAddressMinimum {
//    return [self minAddressFromAddress:self.pickUpAddress];
//}
//
//- (NSString *)deliveryAddressMinimum {
//    return [self minAddressFromAddress:self.deliveryAddress];
//}
//
//- (NSString *)deliveryStatusDescription {
//    NSString *result = @"--";
//    switch ([self.deliveryStatus integerValue]) {
//        case ShipmentStatusPendingPickup:
//            result = @"Approved";
//            break;
//
//        case ShipmentStatusPendingApproval:
//            result = @"Pending Approval";
//            break;
//
//        case ShipmentStatusPendingDelivery:
//            result = @"Enroute";
//            break;
//    }
//    return result;
//}
//
//- (BOOL)deliveryApproved {
//    NSInteger deliveryValue = [self.deliveryStatus integerValue];
//    return deliveryValue == ShipmentStatusPendingPickup || deliveryValue == ShipmentStatusPendingDelivery || deliveryValue == ShipmentStatusDelivered;
//}
//
//- (NSString *)pickUpTimeDescription {
//    return [[HelperFunctions sharedInstance] getDateString:self.pickUpTimeRangeStart withTimeZone:self.pickUpTimeZone];
//}
//
//- (NSString *)deliveryTimeDescription {
//    return [[HelperFunctions sharedInstance] getDateString:self.deliveryTimeRangeStart withTimeZone:self.deliveryTimeZone];
//}
//
//- (NSString *)payoutDescription {
//    if (self.payoutUSD.doubleValue > 0.0 && self.payoutUSD.doubleValue < 999999.0) {
//        return [NSNumberFormatter localizedStringFromNumber:self.payoutUSD
//                                                numberStyle:NSNumberFormatterCurrencyStyle];
//    }
//    else {
//        return self.payoutUSDtext;
//    }
//}
//
//- (NSString *)payoutPerMileDescription {
//    NSNumber *payoutNumber = [NSNumber numberWithFloat:[self.payout_mile floatValue]];
//    NSString *result = [NSNumberFormatter localizedStringFromNumber:payoutNumber
//                                                        numberStyle:NSNumberFormatterCurrencyStyle];
//    if (result == nil) {
//        result = @"--";
//    }
//    return result;
//}
//
//
//- (NSString *)pickUpDistanceDescription {
//    CLLocation *currentLocation = [[LocationCoordinator sharedInstance] lastLocation];
//    if (currentLocation) {
//        CLLocation *pickUpLocation = [[CLLocation alloc] initWithLatitude:self.pickUpCoordinate.latitude
//                                                                longitude:self.pickUpCoordinate.longitude];
//        CLLocationDistance distance = [currentLocation distanceFromLocation:pickUpLocation];
//        MKDistanceFormatter *formatter = [[MKDistanceFormatter alloc] init];
//        formatter.units = MKDistanceFormatterUnitsImperial;
//        return [NSString stringWithFormat:@"%@ away", [formatter stringFromDistance:distance]];
//    }
//    else {
//        return @"--";
//    }
//}
//
//- (NSString *)deliveryDistanceDescription {
//    CLLocation *currentLocation = [[LocationCoordinator sharedInstance] lastLocation];
//    if (currentLocation) {
//        CLLocation *deliveryLocation = [[CLLocation alloc] initWithLatitude:self.deliveryCoordinate.latitude
//                                                                  longitude:self.deliveryCoordinate.longitude];
//        CLLocationDistance distance = [currentLocation distanceFromLocation:deliveryLocation];
//        MKDistanceFormatter *formatter = [[MKDistanceFormatter alloc] init];
//        formatter.units = MKDistanceFormatterUnitsImperial;
//        return [NSString stringWithFormat:@"%@ away", [formatter stringFromDistance:distance]];
//    }
//    else {
//        return @"--";
//    }
//}
//
//- (NSString *)weightDescription {
//    if (!self.weight) {
//        return @"--";
//    }
//    return [NSString stringWithFormat:@"%@ lbs", [NSNumberFormatter localizedStringFromNumber:self.weight numberStyle:NSNumberFormatterNoStyle]];
//}
//
//- (NSString *)palletDescription {
//    if (!self.palletizedValue) {
//        return @"--";
//    }
//    return [NSString stringWithFormat:@"%ldin. x %ldin. x %ldin.", (long)[self.pallet_length integerValue], (long)[self.pallet_width integerValue], (long)[self.pallet_height integerValue]];
//}
//
//- (NSString *)vehicleTypeDescription {
//    return NSStringFromVehicleType(self.vehicleType);
//}
//
//- (NSString *)tripDistanceMilesDescription {
//    NSDecimalNumber *distMiles = self.tripDistanceMiles;
//    NSString *fmtString = distMiles.doubleValue > 10.0 ? @"%.0f miles" : @"%.1f miles";
//    return [NSString stringWithFormat:fmtString, distMiles.floatValue];
//}
//
//
//#pragma mark - Private Instance Methods
//
- (NSDictionary *)stripNullsFromDictionary:(NSDictionary *)aDict {
    NSMutableDictionary *mutDict = [aDict mutableCopy];
    [mutDict removeObjectsForKeys:[mutDict allKeysForObject:[NSNull null]]];
    return [NSDictionary dictionaryWithDictionary:mutDict];
}
//
//- (void)parsePayoutJSON:(NSDictionary *)json {
//    _payoutUSDtext = [json[@"payout_text"] copy];
//    _payoutUSD = [NSDecimalNumber decimalNumberWithString:json[@"payout"]];
//    //Reset value to 0 if DB returns 999999 or greater (default value in DB in v. 1.3.0)
//    NSString* alternativePrice = @"Negotiable";
//    if(self.payoutUSD.doubleValue >= 999999.0 || self.payoutUSD.doubleValue == 0.0){
//        _payoutUSD = (NSDecimalNumber*)[NSDecimalNumber numberWithDouble:0.0];
//        if(self.payoutUSDtext == nil){
//            _payoutUSDtext = alternativePrice;
//        } else if (self.payoutUSDtext.length < 2){
//            _payoutUSDtext = alternativePrice;
//        }
//    }
//
//    _payout_mile = json[@"payout_mile"];
//}
//
//- (void)parseWeightAndPalletJSON:(NSDictionary *)json {
//    _weight = json[@"weight"];
//    _palletized = json[@"palletized"];
//    self.palletizedValue = [self.palletized boolValue];
//    _pallet_height = json[@"pallet_height"];
//    _pallet_length = json[@"pallet_length"];
//    _pallet_width = json[@"pallet_width"];
//    _pallet_number = json[@"pallet_number"];
//    return;
//}
//
//- (NSString *)minAddressFromAddress:(NSString *)address {
//    if([self showMinimizedAddress]) {
//        NSArray *addressComponents = [address componentsSeparatedByString:@", "];
//        NSRange range = NSMakeRange([addressComponents count]-3, 3);
//        NSArray *minAddressComponents = [addressComponents subarrayWithRange:range];
//        NSString *minAddress = [minAddressComponents componentsJoinedByString:@", "];
//        if ([minAddress isEqualToString:address]) {
//            range = NSMakeRange(1, [addressComponents count]-1);
//            minAddressComponents = [addressComponents subarrayWithRange:range];
//            minAddress = [minAddressComponents componentsJoinedByString:@", "];
//        }
//        return minAddress;
//    } else {
//        return address;
//    }
//}
//
//- (BOOL)showMinimizedAddress {
//    if ([self.deliveryStatus integerValue]==ShipmentStatusOpen || [self.deliveryStatus integerValue]==ShipmentStatusPendingApproval || [self.deliveryStatus integerValue]==ShipmentStatusUnknown) {
//        return true;
//    } else {
//        return false;
//    }
//}
//
//- (BOOL)coordinateIsValid:(CLLocationCoordinate2D)coordinate {
//    return CLLocationCoordinate2DIsValid(coordinate)
//        && coordinate.latitude != 0.0f
//        && coordinate.longitude != 0.0f;
//}

@end
