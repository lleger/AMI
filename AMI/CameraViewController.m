//
//  CameraViewController.m
//  AMI
//
//  Created by Logan Leger on 2/18/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import "CameraViewController.h"
#import "MotionManager.h"

NSString *const kSocketHost                   = @"192.168.1.99";
int       const kSocketPort                   = 80;
float     const kUpdateInterval               = 0.1;
float     const kRotationThreshold            = 1.0;
float     const kAttitudeRollForwardThreshold = 1.0;
float     const kAttitudeRollReverseThreshold = 2.0;
float     const kAttitudePitchRightThreshold  = -0.1;
float     const kAttitudePitchLeftThreshold   = 0.0;

@interface CameraViewController ()

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _motionManager = [MotionManager sharedManager];
    
    if (_updateQueue == nil) {
        _updateQueue = [[NSOperationQueue alloc] init];
        _updateQueue.name = @"UpdateQueue";
        _updateQueue.maxConcurrentOperationCount = 1;
    }
    
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err;
    if (![_socket connectToHost:kSocketHost onPort:kSocketPort error:&err]) // Asynchronous!
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

    if ([_motionManager isDeviceMotionAvailable]) {
        [_motionManager setDeviceMotionUpdateInterval:kUpdateInterval];
        [_motionManager startDeviceMotionUpdatesToQueue:_updateQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {
            if (error) {
                NSLog(@"Device motion update error: %@", error);
            }
            [_updateQueue addOperationWithBlock:^{
                [self updateMotionData];
            }];
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([_motionManager isDeviceMotionActive]) {
        [_motionManager stopDeviceMotionUpdates];
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
    
//    _commandLabel.text = commandLabelText;
    [_commandLabel performSelectorOnMainThread:@selector(setText:) withObject:commandLabelText waitUntilDone:YES];
    _currentDirection = command;
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
    
    [_socket writeData:[[commandString stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
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
    CMRotationRate rotationRate = _motionManager.deviceMotion.rotationRate;
    CMAttitude *attitude = _motionManager.deviceMotion.attitude;
    
    if (rotationRate.y <= -kRotationThreshold && attitude.roll < kAttitudeRollForwardThreshold && _currentDirection != DirectionForward) {
        [self changeDirection:DirectionForward];
        [self sendCommandToArduino:DirectionForward];
    } else if (rotationRate.y >= kRotationThreshold && attitude.roll > kAttitudeRollReverseThreshold && _currentDirection != DirectionReverse) {
        [self changeDirection:DirectionReverse];
        [self sendCommandToArduino:DirectionReverse];
    } else if (rotationRate.z < kRotationThreshold && attitude.pitch < kAttitudePitchRightThreshold && _currentDirection != DirectionRight) {
        [self changeDirection:DirectionRight];
        [self sendCommandToArduino:DirectionRight];
    } else if (rotationRate.z > kRotationThreshold && attitude.pitch > kAttitudePitchLeftThreshold && _currentDirection != DirectionLeft) {
        [self changeDirection:DirectionLeft];
        [self sendCommandToArduino:DirectionLeft];
    }
    
    [self updateLabelWithMotionDataWithRotationRate:rotationRate andAttitude:attitude];
}

- (void)updateLabelWithMotionDataWithRotationRate:(CMRotationRate)rotationRate andAttitude:(CMAttitude *)attitude   
{
    NSString *motionText = [NSString stringWithFormat:
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
    [_motionData performSelectorOnMainThread:@selector(setText:) withObject:motionText waitUntilDone:YES];
}

@end
