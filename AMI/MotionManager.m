//
//  MotionManager.m
//  AMI
//
//  Created by Logan Leger on 2/20/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import "MotionManager.h"

@implementation MotionManager

+ (CMMotionManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static CMMotionManager *sharedManager;
    dispatch_once(&onceToken, ^{
        sharedManager = [[CMMotionManager alloc] init];
    });
    return sharedManager;
}

@end
