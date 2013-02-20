//
//  CameraViewController.h
//  AMI
//
//  Created by Logan Leger on 2/18/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "GCDAsyncSocket.h"

typedef enum {
    DirectionForward = 0,
    DirectionReverse,
    DirectionRight,
    DirectionLeft
} DirectionCommand;

@interface CameraViewController : UIViewController <GCDAsyncSocketDelegate>

@property (nonatomic, weak) IBOutlet UILabel *motionData;
@property (nonatomic, weak) IBOutlet UILabel *commandLabel;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, assign) DirectionCommand currentDirection;

- (void)updateMotionData;
- (void)updateLabelWithMotionDataWithRotationRate:(CMRotationRate)rotationRate andAttitude:(CMAttitude*)attitude;
- (void)changeDirection:(DirectionCommand)command;
- (void)sendCommandToArduino:(DirectionCommand)command;

@end
