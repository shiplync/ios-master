//
//  LoadAppViewController.h
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 7/20/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "TraansmissionKit.h"
#import "InitializerProtocol.h"

@interface LoadAppViewController : UIViewController

- (instancetype)initWithCallback:(InitializerCallback)callback;

@end
