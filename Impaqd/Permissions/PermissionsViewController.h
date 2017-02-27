//
//  PermissionsViewController.h
//  Impaqd
//
//  Created by Traansmission on 6/8/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"

@class PermissionsController;

@interface PermissionsViewController : UIViewController

@property (nonatomic, readonly) PermissionsController *permissionsController;
- (instancetype)initWithCompletion:(TRControllerCallback)completion;

@end
