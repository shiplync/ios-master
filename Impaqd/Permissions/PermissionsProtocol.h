//
//  PermissionsProtocol.h
//  Impaqd
//
//  Created by Traansmission on 6/9/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"

@protocol PermissionsProtocol <NSObject>

@required
- (BOOL)isRegisteredForPermissions;
- (dispatch_block_t)permissionBlockWithCompletion:(TRControllerCallback)completion;

@end
