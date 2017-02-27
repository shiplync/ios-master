//
//  ShipmentController.m
//  Impaqd
//
//  Created by Traansmission on 6/15/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "ShipmentController.h"
#import "Shipment.h"

@interface ShipmentController ()

@property (nonatomic, readwrite) Shipment *shipment;

@end

@implementation ShipmentController

- (instancetype)initWithShipment:(Shipment *)shipment {
    self = [super init];
    if (self) {
        self.shipment = shipment;
    }
    return self;
}


#pragma mark - Public Instance Methods

- (NSString *)reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ not implemented in %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];    
}

- (NSString *)titleForCellAtIndexPath:(NSIndexPath *)indexPath {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ not implemented in %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (NSString *)detailForCellAtIndexPath:(NSIndexPath *)indexPath {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ not implemented in %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifierForCellAtIndexPath:indexPath]
                                                            forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self titleForCellAtIndexPath:indexPath];
    cell.detailTextLabel.text = [self detailForCellAtIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
}


#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.0f;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        return height;
    }
    CGFloat availableDetailWidth = CGRectGetWidth(cell.contentView.bounds) - CGRectGetMaxX(cell.textLabel.bounds);
    CGSize detailSize = cell.detailTextLabel.bounds.size;
    CGSize sizeThatFits = [cell.detailTextLabel sizeThatFits:CGSizeMake(availableDetailWidth, CGFLOAT_MAX)];
    if (sizeThatFits.height > detailSize.height) {
        height = sizeThatFits.height + 24.0f;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"TableView (%@) DidSelectRowAtIndexPath (%@)", tableView, indexPath);
}


#pragma mark -

- (NSString *)format_pickUpDateRange:(TRDateRange *)pickUpDateRange {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:self.shipment.pickUpTimeZone];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    return [formatter stringFromDate:pickUpDateRange.startDate];
}


- (NSString *)format_deliveryDateRange:(TRDateRange *)deliveryDateRange {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:self.shipment.deliveryTimeZone];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    return [formatter stringFromDate:deliveryDateRange.startDate];
}

- (NSString *)format_payoutPerMile:(NSNumber *)payoutPerMile {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    return [formatter stringFromNumber:payoutPerMile];
}

- (NSString *)format_vehicleType:(enum VehicleType)vehicleType {
    return NSStringFromVehicleType(vehicleType);
}

- (NSString *)format_tripDistanceMiles:(NSNumber *)tripDistanceMiles {
    NSLengthFormatter *lengthFormatter = [[NSLengthFormatter alloc] init];
    return [lengthFormatter stringFromValue:[tripDistanceMiles doubleValue] unit:NSLengthFormatterUnitMile];
}

- (NSString *)format_weight:(NSNumber *)weight {
    NSMassFormatter *massFormatter = [[NSMassFormatter alloc] init];
    return [massFormatter stringFromValue:[weight doubleValue] unit:NSMassFormatterUnitPound];
}

- (NSString *)format_deliveryStatus:(NSNumber *)deliveryStatus {
    NSString *result = @"--";
    switch ([deliveryStatus integerValue]) {
        case ShipmentStatusPendingPickup:
            result = @"Approved";
            break;
            
        case ShipmentStatusPendingApproval:
            result = @"Pending Approval";
            break;
            
        case ShipmentStatusPendingDelivery:
            result = @"Enroute";
            break;
    }
    return result;
}

- (NSString *)format_shipperPhoneNumber:(NBPhoneNumber *)phoneNumber {
    return [[TRPhoneNumberFormatter defaultFormatter] stringFromPhoneNumber:phoneNumber phoneNumberStyle:PhoneNumberFormatterStyleNational];
}

- (NSString *)format_payoutUSD:(NSNumber *)payoutUSD {
    if (payoutUSD.doubleValue > 0.0 && payoutUSD.doubleValue < 999999.0) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        return [formatter stringFromNumber:payoutUSD];
    }
    else {
        return self.shipment.payoutUSDtext;
    }

}

@end
