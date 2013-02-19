//
//  CameraViewController.h
//  AMI
//
//  Created by Logan Leger on 2/18/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

typedef enum {
    DirectionForward = 0,
    DirectionReverse,
    DirectionRight,
    DirectionLeft
} DirectionCommand;

@interface CameraViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *motionData;
@property (nonatomic, strong) IBOutlet UILabel *commandLabel;
@property (nonatomic, strong) CMMotionManager *motionManager;

- (void)updateMotionData;
- (void)updateLabelWithMotionDataWithRotationRate:(CMRotationRate)rotationRate andAttitude:(CMAttitude*)attitude;
- (void)changeDirection:(DirectionCommand)command;

@end
