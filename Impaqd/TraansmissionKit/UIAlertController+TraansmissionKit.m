//
//  UIAlertController+TraansmissionKit.m
//  Impaqd
//
//  Created by Traansmission on 4/24/15.
//  Copyright (c) 2015 Impaqd. All rights reserved.
//

#import "UIAlertController+TraansmissionKit.h"
#import "NSError+TraansmissionKit.h"

@implementation UIAlertController (TraansmissionKit)

+ (instancetype)alertControllerWithError:(NSError *)error {
    UIAlertController *alert = [self alertControllerWithTitle:[error localizedAlertTitle]
                                                      message:[error localizedAlertMessage]
                                               preferredStyle:UIAlertControllerStyleAlert];
    
    NSArray *recoveryOptions = [error localizedRecoveryOptions];
    if (!recoveryOptions || [recoveryOptions count] == 0) {
        [alert addAction:[self defaultAction]];
    }
    else {
        NSObject *recoveryAttempter = [error recoveryAttempter];
        for (NSString *recoveryOption in recoveryOptions) {
            void (^handler)(UIAlertAction *) = (recoveryAttempter) ? [self handlerForError:error recoveryAttempter:recoveryAttempter] : nil;
            UIAlertAction *action =  [UIAlertAction actionWithTitle:recoveryOption
                                                              style:UIAlertActionStyleDefault
                                                            handler:handler];
            [alert addAction:action];
        }
    }
    
    return alert;
}

#pragma mark - Private Class Methods

+ (UIAlertAction *)defaultAction {
    return [UIAlertAction actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                  handler:[self defaultActionHandler]];
}

+ (UIAlertAction *)actionWithTitle:(NSString *)title recoveryAttempter:(NSObject *)recoveryAttempter {
    if (recoveryAttempter) {
        
    }
    return [UIAlertAction actionWithTitle:title
                                    style:UIAlertActionStyleDefault
                                  handler:[self defaultActionHandler]];
}

+ (void (^)(UIAlertAction *))defaultActionHandler {
    return ^(UIAlertAction * action) {
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] dismissViewControllerAnimated:YES completion:nil];
    };
}

+ (void (^)(UIAlertAction *))handlerForError:(NSError *)error recoveryAttempter:(NSObject *)attempter {
    return ^(UIAlertAction *action) {
        NSArray *recoveryOptions = [error localizedRecoveryOptions];
        NSInteger index = [recoveryOptions indexOfObject:action.title];
        [attempter attemptRecoveryFromError:error optionIndex:index];
    };
}

@end
