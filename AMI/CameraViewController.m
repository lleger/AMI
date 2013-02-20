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

@synthesize motionData, motionManager, commandLabel, socket, currentDirection;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    motionManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err;
    if (![socket connectToHost:@"192.168.1.99" onPort:80 error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"Socket error: %@", err);
    }
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

- (void)changeDirection:(DirectionCommand)command
{
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
    currentDirection = command;
}

- (void)sendCommandToArduino:(DirectionCommand)command
{
    NSString *commandString;
    
    switch (command) {
        case DirectionForward:
            commandString = @"F";
            break;
            
        case DirectionReverse:
            commandString = @"R";
            break;
            
        case DirectionLeft:
            commandString = @"L";
            break;
            
        case DirectionRight:
            commandString = @"R";
            break;
            
        default:
            break;
    }
    
    commandString = [commandString stringByAppendingString:@"\n"];
    
    NSLog(@"Send command to arduino: %@", commandString);
    
    [socket writeData:[[commandString stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"Did connect to host: %@:%i", host, port);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"Socket disconnected with error: %@", err);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"Did write data with tag: %li", tag);
}

- (void)updateMotionData
{
    CMRotationRate rotationRate = motionManager.deviceMotion.rotationRate;
    CMAttitude *attitude = motionManager.deviceMotion.attitude;
    
    if (rotationRate.y <= -kRotationThreshold && attitude.roll < kAttitudeRollForwardThreshold && currentDirection != DirectionForward) {
        [self changeDirection:DirectionForward];
        [self sendCommandToArduino:DirectionForward];
    } else if (rotationRate.y >= kRotationThreshold && attitude.roll > kAttitudeRollReverseThreshold && currentDirection != DirectionReverse) {
        [self changeDirection:DirectionReverse];
        [self sendCommandToArduino:DirectionReverse];
    } else if (rotationRate.z < kRotationThreshold && attitude.pitch < kAttitudePitchRightThreshold && currentDirection != DirectionRight) {
        [self changeDirection:DirectionRight];
        [self sendCommandToArduino:DirectionRight];
    } else if (rotationRate.z > kRotationThreshold && attitude.pitch > kAttitudePitchLeftThreshold && currentDirection != DirectionLeft) {
        [self changeDirection:DirectionLeft];
        [self sendCommandToArduino:DirectionLeft];
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
