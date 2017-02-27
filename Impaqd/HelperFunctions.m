//
//  HelperFunctions.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 7/30/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "HelperFunctions.h"
#import <CoreLocation/CoreLocation.h>
#import "Shipment.h"

@implementation HelperFunctions

+ (id)sharedInstance
{
    static HelperFunctions *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        //initialization
    }
    return self;
}

- (NSString*)getDateString:(NSDate*)date withTimeZone:(NSTimeZone *)tz
{
    return [self getDateString:date withTimeZone:tz dateOnly:NO];
}

- (NSString*)getDateString:(NSDate*)date withTimeZone:(NSTimeZone *)tz dateOnly:(BOOL)dateOnlyFlag
{
    if (date) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];
        NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
        [dateFmt setTimeZone:tz];
        if((minute==0 && hour==0) || dateOnlyFlag){
            dateFmt.dateStyle = NSDateFormatterShortStyle;
            dateFmt.timeStyle = NSDateFormatterNoStyle;
        }else{
            dateFmt.dateStyle = NSDateFormatterShortStyle;
            dateFmt.timeStyle = NSDateFormatterShortStyle;
        }
        if(dateOnlyFlag) {
            return  [NSString stringWithFormat:@"%@", [dateFmt stringFromDate:date]];
        } else {
            return  [NSString stringWithFormat:@"%@ %@", [dateFmt stringFromDate:date], tz.abbreviation];
        }
    }else{
        return nil;
    }
}

-(NSDate *)dateWithOutTime:(NSDate *)datDate
{
    if( datDate == nil ) {
        datDate = [NSDate date];
    }
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:datDate];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (void)convertDateIfNecessary:(Shipment*)shipment
{
    //If date date has this minute:second format XX:59:59, it means we have to remove hour, minute and second from the date.
    //We subtract 5 in order to make sure we get the right date due to time zone differences.
    if(shipment.pickUpTimeRangeEnd){
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:shipment.pickUpTimeRangeEnd];
        NSInteger minute = [components minute];
        NSInteger second = [components second];
        if (minute==59 && second==59) {
            shipment.pickUpTimeRangeStart = [[HelperFunctions sharedInstance] dateWithOutTime:[shipment.pickUpTimeRangeStart dateByAddingTimeInterval:-3600*5]];
            shipment.pickUpTimeRangeEnd = [[HelperFunctions sharedInstance] dateWithOutTime:[shipment.pickUpTimeRangeEnd dateByAddingTimeInterval:-3600*5]];
        }
    }
    
    if(shipment.deliveryTimeRangeEnd){
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:shipment.deliveryTimeRangeEnd];
        NSInteger minute = [components minute];
        NSInteger second = [components second];
        if (minute==59 && second==59) {
            shipment.deliveryTimeRangeStart = [[HelperFunctions sharedInstance] dateWithOutTime:[shipment.deliveryTimeRangeStart dateByAddingTimeInterval:-3600*5]];
            shipment.deliveryTimeRangeEnd = [[HelperFunctions sharedInstance] dateWithOutTime:[shipment.deliveryTimeRangeEnd dateByAddingTimeInterval:-3600*5]];
        }
    }
}


-(NSString*)getServerCoordinateFromLocation:(CLLocation*)location
{
    return [NSString stringWithFormat:@"POINT(%f %f)", location.coordinate.longitude, location.coordinate.latitude];
}

- (NSString*) getPhoneNumberFromString:(NSString*)phoneNumber
{
    return [phoneNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phoneNumber length])];
}

- (NSNumber*)getVehicleTypeNumberFromRowNumber:(NSNumber*)rowNumber
{
    int vehicleTypeNumber;
    switch (rowNumber.integerValue) {
        case 0:
            vehicleTypeNumber = VehicleTypeFlatbed;
            break;
        case 1:
            vehicleTypeNumber = VehicleTypeVan;
            break;
        case 2:
            vehicleTypeNumber = VehicleTypeReefer;
            break;
        case 3:
            vehicleTypeNumber = VehicleTypePowerOnly;
            break;
        default:
            vehicleTypeNumber = VehicleTypeFlatbed;
            break;
    }
    return [NSNumber numberWithInt:vehicleTypeNumber];
}

//This needs to be standardized.
- (NSString*)getDeliveryStatusStringFromNumber:(NSNumber*)number
{
    NSString* deliveryStatus;
    switch (number.integerValue) {
        case 1:
            deliveryStatus = @"Open";
            break;
        case 2:
            deliveryStatus = @"Pending Pickup";
            break;
        case 3:
            deliveryStatus = @"Enroute";
            break;
        case 4:
            deliveryStatus = @"Delivered";
            break;
        case 5:
            deliveryStatus = @"Pending Approval";
            break;
        default:
            deliveryStatus = @"Open";
            break;
    }
    return deliveryStatus;
}

//Simply a modified version of "getDeliveryStatusStringFromNumber".
- (NSString*)getShipperApprovalStatusStringFromNumber:(NSDecimalNumber*)number
{
    NSString* deliveryStatus;
    switch (number.integerValue) {
        case 1:
            deliveryStatus = @"--";
            break;
        case 2:
            deliveryStatus = @"Approved";
            break;
        case 3:
            deliveryStatus = @"--";
            break;
        case 4:
            deliveryStatus = @"--";
            break;
        case 5:
            deliveryStatus = @"Pending Approval";
            break;
        default:
            deliveryStatus = @"Approved";
            break;
    }
    return deliveryStatus;
}


@end
