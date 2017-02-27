//
//  PermissionsController.h
//  SemaphoreScratch
//
//  Created by Traansmission on 5/22/15.
//  Copyright (c) 2015 Traansmission. All rights reserved.
//

#import "TraansmissionKit.h"

@interface PermissionsController : NSObject

+ (BOOL)registerClass:(Class)aClass;
+ (void)unregisterClass:(Class)aClass;

- (void)registerForPermissions:(TRControllerCallback)completion;

@end
