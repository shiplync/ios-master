//
//  HelperFunctions.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 7/30/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Shipment.h"

@interface HelperFunctions : NSObject


+ (id)sharedInstance; 
- (NSString*)getDateString:(NSDate*)date withTimeZone:(NSTimeZone *)tz;
- (NSString*)getDateString:(NSDate*)date withTimeZone:(NSTimeZone *)tz dateOnly:(BOOL)dateOnlyFlag;
- (NSString*)getServerCoordinateFromLocation:(CLLocation*)location;
- (NSDate *)dateWithOutTime:(NSDate *)datDate;
- (void)convertDateIfNecessary:(Shipment*)shipment;
- (NSString*) getPhoneNumberFromString:(NSString*)phoneNumber;
- (NSNumber*)getVehicleTypeNumberFromRowNumber:(NSNumber*)rowNumber;
- (NSString*)getDeliveryStatusStringFromNumber:(NSNumber*)number;
- (NSString*)getShipperApprovalStatusStringFromNumber:(NSNumber*)number;

@end
