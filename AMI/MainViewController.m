//
//  CameraViewController.m
//  AMI
//
//  Created by Logan Leger on 2/18/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import "MainViewController.h"
#import "MotionManager.h"
#import "MotionHandler.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ArduinoTransmitHandler *transmitHandler = [[ArduinoTransmitHandler alloc] init];
    _transmitDelegate = transmitHandler;
    
    ArduinoReceiveHandler *receiveHandler = [[ArduinoReceiveHandler alloc] init];
    _receiveDataSource = receiveHandler;
    [receiveHandler setDelegate:self];
    
    MotionHandler *motionHandler = [[MotionHandler alloc] init];
    _motionDataSource = motionHandler;
    [motionHandler setDelegate:self];
    
//    FIXME:
//    This NSLog is here because everything breaks without it.
//    Yes, this is the most important NSLog EVER. I think it's
//    a bug in ARC, or I'm missing something in my code, but
//    I'll have to come back to this. For now, it's staying put.
    NSLog(@"dataSource: %@", _motionDataSource);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [_transmitDelegate connectToArduino];

    [_receiveDataSource startListening];

    [_motionDataSource startUpdatingMotionData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_transmitDelegate disconnectFromArduino];
    
    [_receiveDataSource stopListening];
    
    [_motionDataSource stopUpdatingMotionData];
}

#pragma mark -
#pragma mark UI methods

- (void)changeDirectionLabel:(Direction)command
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
            
        case DirectionStop:
            commandLabelText = @"Stop";
            break;
            
        default:
            break;
    }
    
    [_commandLabel performSelectorOnMainThread:@selector(setText:)
                                    withObject:commandLabelText waitUntilDone:YES];
}

- (IBAction)stopPressed:(id)sender
{
    [self changeDirectionLabel:DirectionStop];
    [_transmitDelegate writeDirectionCommand:DirectionStop];
}

#pragma mark -
#pragma mark Receive delegate methods

- (void)didReceiveSensorData:(NSArray *)sensorData
{
     NSLog(@"Data received\n");
     NSLog(@"Status: %@ \n", sensorData[0] ? @"OK" : @"Error");
     NSLog(@"Temperature: %i F \n", [sensorData[2] integerValue]);
     NSLog(@"Humidity: %i", [sensorData[1] integerValue]);
}

#pragma mark -
#pragma mark Motion delegate methods

- (void)didUpdateDirection:(Direction)direction
{
    [self changeDirectionLabel:direction];
    [_transmitDelegate writeDirectionCommand:direction];
}

- (void)didUpdateMotionWithRotationRate:(CMRotationRate)rotationRate
                            andAttitude:(CMAttitude *)attitude
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
    [_motionData performSelectorOnMainThread:@selector(setText:)
                                  withObject:motionText waitUntilDone:YES];
}

@end
