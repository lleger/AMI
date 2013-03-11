//
//  MotionHandler.m
//  AMI
//
//  Created by Logan Leger on 3/10/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import "MotionHandler.h"

static float const kUpdateInterval               = 0.1;
static float const kRotationThreshold            = 1.0;
static float const kAttitudeRollForwardThreshold = 1.0;
static float const kAttitudeRollReverseThreshold = 2.0;
static float const kAttitudePitchRightThreshold  = -0.1;
static float const kAttitudePitchLeftThreshold   = 0.0;

@interface MotionHandler()

- (void)determineDirectionFromRotationRate:(CMRotationRate)rotationRate
                               andAttitude:(CMAttitude*)attitude;

@end

@implementation MotionHandler

- (id)init
{
    self = [super init];
    if (self) {
        _motionManager = [MotionManager sharedManager];
        
        _updateQueue = [[NSOperationQueue alloc] init];
        _updateQueue.name = @"UpdateQueue";
        _updateQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)startUpdatingMotionData
{
    if ([_motionManager isDeviceMotionAvailable]) {
        [_motionManager setDeviceMotionUpdateInterval:kUpdateInterval];
        [_motionManager startDeviceMotionUpdatesToQueue:_updateQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {
            if (error) {
                NSLog(@"Device motion update error: %@", error);
            }
            [_updateQueue addOperationWithBlock:^{
                [self determineDirectionFromRotationRate:_motionManager.deviceMotion.rotationRate
                                             andAttitude:_motionManager.deviceMotion.attitude];
                [_delegate didUpdateMotionWithRotationRate:_motionManager.deviceMotion.rotationRate
                                               andAttitude:_motionManager.deviceMotion.attitude];
            }];
        }];
    }
}

- (void)stopUpdatingMotionData
{
    if ([_motionManager isDeviceMotionActive]) {
        [_motionManager stopDeviceMotionUpdates];
    }
}

- (void)determineDirectionFromRotationRate:(CMRotationRate)rotationRate
                               andAttitude:(CMAttitude *)attitude
{
    if (rotationRate.y <= -kRotationThreshold && attitude.roll < kAttitudeRollForwardThreshold && _currentDirection != DirectionForward) {
        _currentDirection = DirectionForward;
        [self.delegate didUpdateDirection:DirectionForward];
    } else if (rotationRate.y >= kRotationThreshold && attitude.roll > kAttitudeRollReverseThreshold && _currentDirection != DirectionReverse) {
        _currentDirection = DirectionReverse;
        [self.delegate didUpdateDirection:DirectionReverse];
    } else if (rotationRate.z < kRotationThreshold && attitude.pitch < kAttitudePitchRightThreshold && _currentDirection != DirectionRight) {
        _currentDirection = DirectionRight;
        [self.delegate didUpdateDirection:DirectionRight];
    } else if (rotationRate.z > kRotationThreshold && attitude.pitch > kAttitudePitchLeftThreshold && _currentDirection != DirectionLeft) {
        _currentDirection = DirectionLeft;
        [self.delegate didUpdateDirection:DirectionLeft];
    }
}

@end
