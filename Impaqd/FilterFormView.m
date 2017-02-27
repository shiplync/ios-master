//
//  FilterFormView.m
//  Impaqd
//
//  Created by Greg Nicholas on 2/19/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "FilterFormView.h"
#import "FilterFormStepperCell.h"
#import "AvailableShipmentSearchParameters.h"
#import "HelperFunctions.h"

static const NSTimeInterval secondsBetweenStepperAnalyticsUpdate = 10;

@interface FilterFormView ()
{
    UITableViewCell *vehicleTypeCell;
    FilterFormStepperCell *maxTripDistanceCell;
    FilterFormStepperCell *maxPickUpDistanceCell;

    UIDatePicker *earliestPickUpPicker;
    UITableViewCell *earliestPickUpCell;
    UITableViewCell *earliestPickUpEditCell;
    
    UITableViewCell *orderingCellDistance;
    UITableViewCell *orderingCellPickUpTime;
    
    UIActionSheet *vehicleTypeSelect;
    
    NSDateFormatter *dateFormatter;
    
    NSDate *_nextMaxTripDistanceAnalyticsUpdateDue;
    NSDate *_nextMaxPickupDistanceAnalyticsUpdateDue;
}

@property (nonatomic, assign) BOOL isEditingPickUpTime;
@property (nonatomic, assign) BOOL isEditingDeliveryTime;

- (void)initializeCells;
- (void)syncFormValues;
- (void)maxTripValueChanged;
- (void)maxPickUpDistanceChanged;
- (void)earliestPickUpTimeChanged;

@end

static NSDate * roundUpToNext15Minutes(NSDate *date) {
    NSCalendarUnit units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:date];
    components.minute = ceil(components.minute/15.0) * 15.0;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

/**
 *  TODO: Consider using a form-building library -- this is all from-scratch manual form-building.
 */

@implementation FilterFormView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)awakeFromNib
{
    [self _init];
}

/**
 *  Initialize method called by both initWithFrame and awakeFromNib.
 */
- (void)_init
{
    self.delegate = self;
    self.dataSource = self;
    
    UINib* nib = [UINib nibWithNibName:@"FilterFormStepperCell" bundle:nil];
    [self registerNib:nib forCellReuseIdentifier:@"FilterFormStepperCell"];

    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    self.searchParams = [AvailableShipmentSearchParameters sharedInstance];
    
    [self.searchParams updateTimeParameters];
    
    [self initializeCells];
    
    _nextMaxPickupDistanceAnalyticsUpdateDue = [NSDate date];
    _nextMaxTripDistanceAnalyticsUpdateDue = [NSDate date];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /**
     *  Rows are as follows:
        0. Distance away
        1. Total trip distance
        2. Min payout *REMOVED
        3. Earliest pick up
        4. Latest drop-off *REMOVED
        5. Required vehicle
        6. Ordering
     */
    
    switch (section) {
        case 2:
            return self.isEditingPickUpTime ? 2 : 1;
        case 4:
            return 2;
        default:
            return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Pick Up Distance";
        case 1:
            return @"Total Trip Distance";
        case 2:
            return @"Earliest Pick Up";
        case 3:
            return @"Required Vehicle";
        case 4:
            return @"Ordering";
        default:
            return nil;
    }
    
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Farthest you're willing to go to pick up";
        case 1:
            return @"Max distance from pick-up to delivery";
        default:
            return nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return maxPickUpDistanceCell;
        case 1:
            return maxTripDistanceCell;
        case 2:
            return indexPath.row == 0 ? earliestPickUpCell : earliestPickUpEditCell;
        case 3:
            return vehicleTypeCell;
        case 4:
            if (indexPath.row == 0) {
                return orderingCellDistance;
            }
            else {
                return orderingCellPickUpTime;
            }
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0) {
        if (self.isEditingDeliveryTime) {
            self.isEditingDeliveryTime = NO;
        }
        self.isEditingPickUpTime = !self.isEditingPickUpTime;
    }
    else if (indexPath.section == 3) {
        vehicleTypeSelect = [[UIActionSheet alloc] initWithTitle:@"Select vehicle type"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Flatbed", @"Van", @"Reefer", @"Power only", nil];
        [vehicleTypeSelect showInView:tableView];
        return;
    }
    else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            orderingCellDistance.accessoryType = UITableViewCellAccessoryCheckmark;
            self.searchParams.orderingType = ShipmentFetchOrderingTypeByProximity;
            orderingCellPickUpTime.accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            orderingCellDistance.accessoryType = UITableViewCellAccessoryNone;
            orderingCellPickUpTime.accessoryType = UITableViewCellAccessoryCheckmark;
            self.searchParams.orderingType = ShipmentFetchOrderingTypeByPickUpTime;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 1) {
        return 212;
    }
    return 44;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == vehicleTypeSelect && buttonIndex < 4) {
        NSNumber *typeNumber = [[HelperFunctions sharedInstance] getVehicleTypeNumberFromRowNumber:[NSNumber numberWithInteger:buttonIndex]];
        enum VehicleType vehicleType = VehicleTypeFromNSNumber(typeNumber);
        vehicleTypeCell.textLabel.text = NSStringFromVehicleType(vehicleType);
        self.searchParams.vehicleType = vehicleType;
    }
    [self deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] animated:NO];
}

- (void)maxTripValueChanged
{
    self.searchParams.maximumTripDistance = maxTripDistanceCell.stepper.value;
    [self syncFormValues];
}

- (void)maxPickUpDistanceChanged
{
    self.searchParams.searchRadius = maxPickUpDistanceCell.stepper.value * 1609.34;
    [self syncFormValues];
}

- (void)earliestPickUpTimeChanged
{
    self.searchParams.pickUpTime = earliestPickUpPicker.date;
    [self syncFormValues];

}

- (void)initializeCells
{
    maxPickUpDistanceCell = [self dequeueReusableCellWithIdentifier:@"FilterFormStepperCell"];
    maxPickUpDistanceCell.stepper.maximumValue = 3000;
    maxPickUpDistanceCell.stepper.minimumValue = 50;
    maxPickUpDistanceCell.stepper.stepValue = 50;
    [maxPickUpDistanceCell.stepper addTarget:self action:@selector(maxPickUpDistanceChanged) forControlEvents:UIControlEventValueChanged];
    
    maxTripDistanceCell = [self dequeueReusableCellWithIdentifier:@"FilterFormStepperCell"];
    maxTripDistanceCell.stepper.maximumValue = 10000;
    maxTripDistanceCell.stepper.minimumValue = 100;
    maxTripDistanceCell.stepper.stepValue = 100;
    [maxTripDistanceCell.stepper addTarget:self action:@selector(maxTripValueChanged) forControlEvents:UIControlEventValueChanged];
    
    earliestPickUpCell = [[UITableViewCell alloc] init];
    earliestPickUpCell.textLabel.text = [dateFormatter stringFromDate:self.searchParams.pickUpTime];
    earliestPickUpEditCell = [[UITableViewCell alloc] init];
    earliestPickUpPicker = [[UIDatePicker alloc] init];
    earliestPickUpPicker.minuteInterval = 15;
    earliestPickUpPicker.minimumDate = [NSDate date];
    [earliestPickUpPicker addTarget:self action:@selector(earliestPickUpTimeChanged) forControlEvents:UIControlEventValueChanged];
    [earliestPickUpEditCell.contentView addSubview:earliestPickUpPicker];

    earliestPickUpEditCell.clipsToBounds = YES;
    
    vehicleTypeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    orderingCellDistance = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    orderingCellDistance.textLabel.text = @"Closest To Me";
    
    orderingCellPickUpTime = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    orderingCellPickUpTime.textLabel.text = @"Soonest Pick Up";

    [self syncFormValues];
}

- (void)syncFormValues
{
    maxPickUpDistanceCell.stepper.value = self.searchParams.searchRadius * 0.000621371;
    maxPickUpDistanceCell.valueLabel.text = [NSString stringWithFormat:@"%.0f miles", maxPickUpDistanceCell.stepper.value];
    
    maxTripDistanceCell.stepper.value = self.searchParams.maximumTripDistance;
    maxTripDistanceCell.valueLabel.text = [NSString stringWithFormat:@"%.0f miles", maxTripDistanceCell.stepper.value];
    
    earliestPickUpCell.textLabel.text = [dateFormatter stringFromDate:roundUpToNext15Minutes(self.searchParams.pickUpTime)];
    earliestPickUpPicker.date = self.searchParams.pickUpTime;

    vehicleTypeCell.textLabel.text = NSStringFromVehicleType(self.searchParams.vehicleType);
    
    switch (self.searchParams.orderingType) {
        case ShipmentFetchOrderingTypeByProximity:
            orderingCellDistance.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        case ShipmentFetchOrderingTypeByPickUpTime:
            orderingCellPickUpTime.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        default:
            break;
    }
}

- (void)setIsEditingPickUpTime:(BOOL)isEditingPickUpTime
{
    _isEditingPickUpTime = isEditingPickUpTime;
    
    [self beginUpdates];
    
    if (isEditingPickUpTime) {
        [self insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [self deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
        // ensure delivery time makes sense post-editing
        if ([self.searchParams.deliveryTime timeIntervalSinceDate:self.searchParams.pickUpTime] < 0) {
            self.searchParams.deliveryTime = [self.searchParams.pickUpTime dateByAddingTimeInterval:900];
            [self syncFormValues];
        }
    }
    
    [self endUpdates];
    
    earliestPickUpCell.textLabel.textColor = isEditingPickUpTime ? [self tintColor] : [UIColor blackColor];
}

@end
