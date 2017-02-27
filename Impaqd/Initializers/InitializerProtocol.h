//
//  InitializerProtocol.h
//  Impaqd
//
//  Created by Traansmission on 4/24/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^InitializerCallback)(NSError *);

@protocol InitializerProtocol <NSObject>

- (instancetype)initWithCallback:(InitializerCallback)callback;

- (void)didFinishLaunching;
- (void)willEnterForeground;
- (void)didEnterBackground;

@end
