//
//  MotionManager.h
//  AMI
//
//  Created by Logan Leger on 2/20/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface MotionManager : NSObject

+ (CMMotionManager *)sharedManager;

@end
