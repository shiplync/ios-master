//
//  OpenShipmentController.m
//  Impaqd
//
//  Created by Traansmission on 6/12/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "OpenShipmentController.h"
#import "Shipment.h"
#import "LocationType.h"

NS_ENUM(NSUInteger, ShipmentDetailSection) {
    ShipmentDetailSectionLocations = 0,
    ShipmentDetailSectionPickup,
    ShipmentDetailSectionDelivery,
    ShipmentDetailSectionInfo,
};
NSInteger LOCATION_SECTION_OFFSET = 1;

@implementation OpenShipmentController

+ (void)load {

}

- (BOOL) isLocationSection:(NSInteger) section
{
    if (section >= LOCATION_SECTION_OFFSET && section <= self.shipment.locations.count + LOCATION_SECTION_OFFSET) {
        return YES;
    } else {
        return NO;
    }
}

- (NSArray*) getFormattedSectionData:(NSInteger)section
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    void(^addToResults)(NSString*, NSString*) = ^(NSString *value, NSString *label) {
        if(value && ![value isKindOfClass:[NSError class]]) {
            [results addObject:@{@"label":label, @"value":value}];
        }
    };
    
    if([self isLocationSection:section]) {
        Location *location = self.shipment.locations[section-LOCATION_SECTION_OFFSET];
        
        LocationType *locationType = location.locationType;
        addToResults(locationType.label, @"Location type");

        TimeRange *timeRange = location.timeRange;
        addToResults(timeRange.timeRangeStartDescription, @"Arrive by (earliest)");
        addToResults(timeRange.timeRangeEndDescription, @"Arrive by (latest)");
        addToResults(location.arrivalTimeDescription, @"Arrived at");
        addToResults(location.companyName, @"Company");
        
        AddressDetails *addressDetails = location.addressDetails;
        addToResults(addressDetails.joinedAddress, @"Address");
        
        Person *contact = location.contact;
        addToResults(contact.name, @"Contact name");
        addToResults(contact.phone, @"Contact phone");
        addToResults(contact.email, @"Contact email");
        
        ShipmentFeatures *features = location.features;
        addToResults([NSString stringWithFormat:@"%@", features.weight], @"Weight");        
        addToResults(features.isPalletized ? @"Yes" : nil, @"Is palletized");
        addToResults(features.palletNumber ? [NSString stringWithFormat:@"%@",features.palletNumber] : nil, @"# of pallets");
        addToResults(features.palletDimensions, @"Pallet dimensions");
        
    } else {
        addToResults(self.shipment.deliveryStatus.label, @"Status");
        addToResults(self.shipment.bolNumber, @"BOL number");
        addToResults(self.shipment.formattedTripDistance, @"Trip distance");
        addToResults(self.shipment.payoutInfo.formattedPayout, @"Cost");
        addToResults(self.shipment.payoutInfo.formattedPayoutDistance, @"Cost per mile");
        
        NSDictionary *equipmentTagsDict = self.shipment.formattedEquipmentTags;
        NSEnumerator *enumerator = [equipmentTagsDict keyEnumerator];
        NSString *key;
        while ( (key = [enumerator nextObject]) != nil) {
            NSString *value = [[equipmentTagsDict objectForKey:key] componentsJoinedByString:@", "];
            addToResults(value, key);
        }

    }
    
    return results;
}


#pragma mark - ShipmentController Overrides

- (NSString *)reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath {
    return @"ShipmentDetailCell";
}

- (NSString *)titleForCellAtIndexPath:(NSIndexPath *)indexPath {
    return [[self getFormattedSectionData:indexPath.section][indexPath.row] objectForKey:@"label"];
}

- (NSString *)detailForCellAtIndexPath:(NSIndexPath *)indexPath {
    return [[self getFormattedSectionData:indexPath.section][indexPath.row] objectForKey:@"value"];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.shipment.locations.count + LOCATION_SECTION_OFFSET;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getFormattedSectionData:section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self isLocationSection:section]) {
        return [NSString stringWithFormat:@"Location %ld", (long)section - LOCATION_SECTION_OFFSET + 1];
    } else {
        return @"Shipment details";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return section == [self numberOfSectionsInTableView:tableView]-1 ? [NSString stringWithFormat:@"Shipment ID: %@", self.shipment.shipmentId] : nil;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"TableView (%@) DidSelectRowAtIndexPath (%@)", tableView, indexPath);
}

@end
