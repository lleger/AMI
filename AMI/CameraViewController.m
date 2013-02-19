//
//  CameraViewController.m
//  AMI
//
//  Created by Logan Leger on 2/18/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import "CameraViewController.h"
#import "AppDelegate.h"

const float kUpdateInterval = 0.01;
const float kRotationThreshold = 1.0;
const float kAttitudeRollForwardThreshold = 1.0;
const float kAttitudeRollReverseThreshold = 2.0;
const float kAttitudePitchRightThreshold = -0.1;
const float kAttitudePitchLeftThreshold = 0.0;

@interface CameraViewController ()

@end

@implementation CameraViewController

@synthesize motionData, motionManager, commandLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    motionManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([motionManager isDeviceMotionAvailable]) {
        [motionManager startDeviceMotionUpdates];
        [NSTimer scheduledTimerWithTimeInterval:kUpdateInterval target:self selector:@selector(updateMotionData) userInfo:nil repeats:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([motionManager isDeviceMotionActive]) {
        [motionManager stopDeviceMotionUpdates];
    }
}

- (void)changeDirection:(DirectionCommand)command {
    NSString *commandLabelText;
    
    switch (command) {
        case DirectionForward:
            commandLabelText = @"Forward";
            break;
            
        case DirectionReverse:
            commandLabelText = @"Reverse";
            break;
            
        case DirectionLeft:
            commandLabelText = @"Left";
            break;
            
        case DirectionRight:
            commandLabelText = @"Right";
            break;
            
        default:
            break;
    }
    
    commandLabel.text = commandLabelText;    
}

- (void)updateMotionData
{
    CMRotationRate rotationRate = motionManager.deviceMotion.rotationRate;
    CMAttitude *attitude = motionManager.deviceMotion.attitude;
    
    if (rotationRate.y <= -kRotationThreshold && attitude.roll < kAttitudeRollForwardThreshold) {
        [self changeDirection:DirectionForward];
    } else if (rotationRate.y >= kRotationThreshold && attitude.roll > kAttitudeRollReverseThreshold) {
        [self changeDirection:DirectionReverse];
    } else if (rotationRate.z < kRotationThreshold && attitude.pitch < kAttitudePitchRightThreshold) {
        [self changeDirection:DirectionRight];
    } else if (rotationRate.z > kRotationThreshold && attitude.pitch > kAttitudePitchLeftThreshold) {
        [self changeDirection:DirectionLeft];
    }
    
    [self updateLabelWithMotionDataWithRotationRate:rotationRate andAttitude:attitude];
}

- (void)updateLabelWithMotionDataWithRotationRate:(CMRotationRate)rotationRate andAttitude:(CMAttitude *)attitude   
{    
    motionData.text = [NSString stringWithFormat:
                       @"Roll: %f\n"
                       @"Pitch: %f\n"
                       @"Yaw: %f\n"
                       @"Rot rate X: %f\n"
                       @"Rot rate Y: %f\n"
                       @"Rot rate Z: %f",
                       attitude.roll,
                       attitude.pitch,
                       attitude.yaw,
                       rotationRate.x,
                       rotationRate.y,
                       rotationRate.z];
}

@end
