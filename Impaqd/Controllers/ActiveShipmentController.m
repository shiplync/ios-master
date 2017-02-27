//
//  ActiveShipmentController.m
//  Impaqd
//
//  Created by Traansmission on 6/15/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "ActiveShipmentController.h"
#import "Shipment.h"

NS_ENUM(NSUInteger, ActiveShipmentDetailSection) {
    ActiveShipmentDetailSectionPickup = 0,
    ActiveShipmentDetailSectionInfo,
    ActiveShipmentDetailSectionDelivery
};

@interface ActiveShipmentController ()

@property (nonatomic) NSArray *infoSectionReuseIdentifiers;
@property (nonatomic) NSArray *infoSectionCellTitles;
@property (nonatomic) NSArray *infoSectionCellValueKeys;

@end

@implementation ActiveShipmentController

static NSArray *__cellTitles;
static NSArray *__cellValueKeys;
static NSArray *__cellReuseIdentifiers;

+ (void)load {
    __cellTitles = @[ @[ @"Approval Status", @"Company", @"Location", @"Pick Up Time" ],
                      @[ @"Payout", @"Payout per Mile", @"Approx. Trip Distance", @"Weight", @"Shipper Phone" ],
                      @[ @"Company", @"Location", @"Delivery Time" ]
                      ];
    
    __cellValueKeys = @[ @[ @"deliveryStatus", @"shipperName", @"pickUpAddressMinimum", @"pickUpDateRange" ],
                         @[ @"payoutUSD", @"payoutPerMileDescription", @"vehicleTypeDescription", @"tripDistanceMiles", @"shipperPhoneNumber" ],
                         @[ @"receiverName", @"deliveryAddressMinimum", @"deliveryDateRange" ]
                         ];
    
    __cellReuseIdentifiers = @[ @[ @"ShipmentDetailCell", @"ShipmentDetailCell", @"ShipmentLinkDetailCell", @"ShipmentDetailCell" ],
                                @[ @"ShipmentDetailCell", @"ShipmentDetailCell", @"ShipmentDetailCell", @"ShipmentDetailCell", @"ShipmentLinkDetailCell" ],
                                @[ @"ShipmentDetailCell", @"ShipmentLinkDetailCell", @"ShipmentDetailCell" ]
                                ];
}


#pragma mark - ShipmentController Overrides

- (NSString *)reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ActiveShipmentDetailSectionInfo) {
        return self.infoSectionReuseIdentifiers[indexPath.row];
    }
    return __cellReuseIdentifiers[indexPath.section][indexPath.row];
}

- (NSString *)titleForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ActiveShipmentDetailSectionInfo) {
        return self.infoSectionCellTitles[indexPath.row];
    }
    return __cellTitles[indexPath.section][indexPath.row];
}

- (NSString *)detailForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *valueKeys = (indexPath.section == ActiveShipmentDetailSectionInfo) ? self.infoSectionCellValueKeys
                                                                                : __cellValueKeys[indexPath.section];
    NSString *detail;
    NSString *propertyName = valueKeys[indexPath.row];
    NSString *selectorName = [NSString stringWithFormat:@"format_%@:", propertyName];
    SEL selector = NSSelectorFromString(selectorName);
    if ([self respondsToSelector:selector]) {
        IMP imp = [self methodForSelector:selector];
        NSString * (*func)(id, SEL, id) = (void *)imp;
        detail = func(self, selector, [self.shipment valueForKey:propertyName]);
    }
    else {
        detail = [[self.shipment valueForKey:propertyName] description];
    }
    return detail;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberOfRows;
    enum ActiveShipmentDetailSection detailSection = section;
    switch (detailSection) {
        case ActiveShipmentDetailSectionPickup:
            numberOfRows = 4;
            break;

        case ActiveShipmentDetailSectionInfo:
            numberOfRows = 5;
            if (self.shipment.palletizedValue) {
                numberOfRows += 1;
            }
            if (self.shipment.extraDetails) {
                numberOfRows += 1;
            }
            break;
            
        case ActiveShipmentDetailSectionDelivery:
            numberOfRows = 3;
            break;
    }
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header;
    enum ActiveShipmentDetailSection detailSection = section;
    switch (detailSection) {
        case ActiveShipmentDetailSectionPickup:
            header = @"PICK UP DETAILS";
            break;
            
        case ActiveShipmentDetailSectionInfo:
            header = @"SHIPMENT INFO";
            break;
            
        case ActiveShipmentDetailSectionDelivery:
            header = @"DELIVERY INFO";
            break;
    }
    return header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *footer;
    enum ActiveShipmentDetailSection detailSection = section;
    switch (detailSection) {
        case ActiveShipmentDetailSectionPickup:
        case ActiveShipmentDetailSectionInfo:
            break;

        case ActiveShipmentDetailSectionDelivery:
            footer = [NSString stringWithFormat:@"Shipment ID: %@", self.shipment.shipmentId];
            break;
    }
    return footer;
}

#pragma mark - Private Instance Methods

- (NSArray *)infoSectionReuseIdentifiers {
    if (_infoSectionReuseIdentifiers == nil) {
        NSMutableArray *reuseIdentifiers = [__cellReuseIdentifiers[ActiveShipmentDetailSectionInfo] mutableCopy];
        if (self.shipment.palletizedValue) {
            [reuseIdentifiers insertObject:@"ShipmentDetailCell" atIndex:4];
        }
        if (self.shipment.extraDetails) {
            [reuseIdentifiers addObject:@"ShipmentDetailCell"];
        }
        _infoSectionReuseIdentifiers = [NSArray arrayWithArray:reuseIdentifiers];
    }
    return _infoSectionReuseIdentifiers;
}

- (NSArray *)infoSectionCellTitles {
    if (_infoSectionCellTitles == nil) {
        NSMutableArray *titles = [__cellTitles[ActiveShipmentDetailSectionInfo] mutableCopy];
        if (self.shipment.palletizedValue) {
            [titles insertObject:@"Pallet Dimensions (l,w,h)" atIndex:4];
        }
        if (self.shipment.extraDetails) {
            [titles addObject:@"Details"];
        }
        _infoSectionCellTitles = [NSArray arrayWithArray:titles];
    }
    return _infoSectionCellTitles;
}

- (NSArray *)infoSectionCellValueKeys {
    if (_infoSectionCellValueKeys == nil) {
        NSMutableArray *titles = [__cellValueKeys[ActiveShipmentDetailSectionInfo] mutableCopy];
        if (self.shipment.palletizedValue) {
            [titles insertObject:@"palletDescription" atIndex:4];
        }
        if (self.shipment.extraDetails) {
            [titles addObject:@"extraDetails"];
        }
        _infoSectionCellValueKeys = [NSArray arrayWithArray:titles];
    }
    return _infoSectionCellValueKeys;
}

@end
