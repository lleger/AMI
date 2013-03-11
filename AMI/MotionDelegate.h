//
//  MotionDelegate.h
//  AMI
//
//  Created by Logan Leger on 3/10/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DirectionForward = 0,
    DirectionReverse,
    DirectionRight,
    DirectionLeft,
    DirectionStop
} Direction;

@protocol MotionDelegate <NSObject>

- (void)didUpdateMotionWithRotationRate:(CMRotationRate)rotationRate
                            andAttitude:(CMAttitude *)attitude;
- (void)didUpdateDirection:(Direction)direction;

@end
