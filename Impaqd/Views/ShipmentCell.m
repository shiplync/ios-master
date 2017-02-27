//
//  ActiveShipmentCell.m
//  Impaqd
//
//  Created by Traansmission on 4/28/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "ShipmentCell.h"
#import "Shipment.h"

@interface ShipmentCell ()

@property (nonatomic) UILabel *textLabelTop;
@property (nonatomic) UILabel *textLabelMiddle;
@property (nonatomic) UILabel *textLabelBottom;

@property (nonatomic) UILabel *detailLabelTop;
@property (nonatomic) UILabel *detailLabelMiddle;
@property (nonatomic) UILabel *detailLabelBottom;

@end

@implementation ShipmentCell

- (void)awakeFromNib {
    // Initialization code
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self initializeSubviews];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    if ([[self.contentView constraints] count] == 0) {
        [self initializeConstraints];
    }
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.textLabelTop.text = @"text";
    self.textLabelMiddle.text = @"text";
    self.textLabelBottom.text = @"text";
    self.detailLabelTop.text = @"detail";
    self.detailLabelMiddle.text = @"detail";
    self.detailLabelBottom.text = @"detail";
    [self.detailLabelTop setFont:[UIFont boldSystemFontOfSize:15.0f]];
    [self setNeedsLayout];
}

- (void)setStyle:(enum ShipmentCellStyle)style {
    if (_style == style) {
        return;
    }
    _style = style;
}

- (void)setShipment:(Shipment *)shipment {
    _shipment = shipment;
//    [self setTextLabels];
//    [self setDetailLabels];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Private Instance Methods

- (void)initializeSubviews {
    self.textLabelTop = [self textLabel];
    self.textLabelMiddle = [self textLabel];
    self.textLabelBottom = [self textLabel];
    
    self.detailLabelTop = [self detailLabel];
    self.detailLabelMiddle = [self detailLabel];
    self.detailLabelBottom = [self detailLabel];
}

- (void)initializeConstraints {
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_textLabelTop, _textLabelMiddle, _textLabelBottom,
                                                                   _detailLabelTop, _detailLabelMiddle, _detailLabelBottom);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_textLabelTop]-[_detailLabelTop]-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_textLabelMiddle]-[_detailLabelMiddle]"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_textLabelBottom]-[_detailLabelBottom]"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_textLabelTop]-[_textLabelMiddle]-[_textLabelBottom]-|"
                                                                             options:NSLayoutFormatAlignAllLeading
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.textLabelBottom
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0f
                                                                  constant:8.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}

- (UILabel *)textLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [label setFont:[UIFont systemFontOfSize:15.0f]];
    [label setText:@"text"];
    [label sizeToFit];
    [self.contentView addSubview:label];
    return label;
}

- (UILabel *)detailLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [label setFont:[UIFont boldSystemFontOfSize:15.0f]];
    [label setText:@"detail"];
    [label sizeToFit];
    [self.contentView addSubview:label];
    return label;
}

//- (void)setTextLabels {
//    switch (self.style) {
//        case ShipmentCellStyleActive:
//            [self setActiveTextLabels];
//            break;
//        case ShipmentCellStyleAvailable:
//            break;
//        case ShipmentCellStyleComplete:
//            [self setCompletedTextLabels];
//            break;
//        case ShipmentCellStyleUnknown:
//            break;
//    }
//}

//- (void)setActiveTextLabels {
//    if ([self.shipment.deliveryStatus integerValue] == ShipmentStatusPendingApproval) {
//        [self setActiveApprovalTextLabels];
//    }
//    else if ([self.shipment.deliveryStatus integerValue] == ShipmentStatusPendingPickup) {
//        [self setActivePickupTextLabels];
//    }
//    else if ([self.shipment.deliveryStatus integerValue] == ShipmentStatusPendingDelivery) {
//        [self setActiveDeliveryTextLabels];
//    }
//}

//- (void)setCompletedTextLabels {
//    self.textLabelTop.text = @"Shipment ID";
//    self.textLabelMiddle.text = @"Payout";
//    self.textLabelBottom.text = @"Delivered";
//}
//
//- (void)setActiveApprovalTextLabels {
//    self.textLabelTop.text = @"Payout";
//    self.textLabelMiddle.text = @"Pickup Time";
//    self.textLabelBottom.text = @"Distance";
//}
//
//- (void)setActivePickupTextLabels {
//    self.textLabelTop.text = @"Payout";
//    self.textLabelMiddle.text = @"Pickup Time";
//    self.textLabelBottom.text = @"Distance";
//}
//
//- (void)setActiveDeliveryTextLabels {
//    self.textLabelTop.text = @"Payout";
//    self.textLabelMiddle.text = @"Delivery Time";
//    self.textLabelBottom.text = @"Distance";
//}

//- (void)setDetailLabels {
//    switch (self.style) {
//        case ShipmentCellStyleActive:
//            [self setActiveDetailLabels];
//            break;
//        case ShipmentCellStyleAvailable:
//            break;
//        case ShipmentCellStyleComplete:
//            [self setCompletedDetailLabels];
//            break;
//        case ShipmentCellStyleUnknown:
//            break;
//    }
//}
//
//- (void)setActiveDetailLabels {
//    if ([self.shipment.deliveryStatus integerValue] == ShipmentStatusPendingApproval) {
//        [self setActiveApprovalDetailLabels];
//    }
//    else if ([self.shipment.deliveryStatus integerValue] == ShipmentStatusPendingPickup) {
//        [self setActivePickupDetailLabels];
//    }
//    else if ([self.shipment.deliveryStatus integerValue] == ShipmentStatusPendingDelivery) {
//        [self setActiveDeliveryDetailLabels];
//    }
//}
//
//- (void)setCompletedDetailLabels {
//    [self.detailLabelTop setFont:[UIFont boldSystemFontOfSize:12.0f]];
//    self.detailLabelTop.text = self.shipment.shipmentId;
//    self.detailLabelMiddle.text = self.shipment.payoutDescription;
//    self.detailLabelBottom.text = [NSDateFormatter localizedStringFromDate:self.shipment.deliveredAt
//                                                                 dateStyle:NSDateFormatterShortStyle
//                                                                 timeStyle:NSDateFormatterShortStyle];
//}
//
//- (void)setActiveApprovalDetailLabels {
//    self.detailLabelTop.text = self.shipment.payoutDescription;
//    self.detailLabelMiddle.text = self.shipment.pickUpTimeDescription;
//    self.detailLabelBottom.text = self.shipment.pickUpDistanceDescription;
//}
//
//- (void)setActivePickupDetailLabels {
//    self.detailLabelTop.text = self.shipment.payoutDescription;
//    self.detailLabelMiddle.text = self.shipment.pickUpTimeDescription;
//    self.detailLabelBottom.text = self.shipment.pickUpDistanceDescription;
//}
//
//- (void)setActiveDeliveryDetailLabels {
//    self.detailLabelTop.text = self.shipment.payoutDescription;
//    self.detailLabelMiddle.text = self.shipment.deliveryTimeDescription;
//    self.detailLabelBottom.text = self.shipment.deliveryDistanceDescription;
//}

@end
