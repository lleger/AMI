//
//  CameraViewController.m
//  AMI
//
//  Created by Logan Leger on 2/18/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _cameraLayer = [[CALayer alloc] init];
    _cameraLayer.frame = CGRectMake(192.f, 257.f, 640.f, 480.f);
    [self.view.layer addSublayer:_cameraLayer];
    
    _transmitDelegate = [[ArduinoTransmitHandler alloc] init];
    
    _receiveDataSource = [[ArduinoReceiveHandler alloc] init];
    [_receiveDataSource setDelegate:self];
    
    _motionDataSource = [[MotionHandler alloc] init];
    [_motionDataSource setDelegate:self];
    
    _cameraDataSource = [[CameraHandler alloc] init];
    [_cameraDataSource setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [_transmitDelegate connectToArduino];

    [_receiveDataSource startListening];

    [_motionDataSource startUpdatingMotionData];
    
    [_cameraDataSource startStreaming];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_transmitDelegate disconnectFromArduino];
    
    [_receiveDataSource stopListening];
    
    [_motionDataSource stopUpdatingMotionData];
    
    [_cameraDataSource stopStreaming];
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

#pragma mark -
#pragma mark Camera delegate methods

- (void)didReceiveCameraData:(NSData *)cameraData
{
    [_cameraLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    CALayer *frameLayer = [CALayer layer];
    frameLayer.frame = _cameraLayer.bounds;
    CFDataRef frameData = CFDataCreate(NULL, [cameraData bytes], [cameraData length]);
    CGDataProviderRef imgDataProvider;
    CGImageRef cameraFrame;
    imgDataProvider = CGDataProviderCreateWithCFData(frameData);
    CFRelease(frameData);
    cameraFrame = CGImageCreateWithJPEGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(imgDataProvider);
    [frameLayer setContents:(__bridge id)(cameraFrame)];
    [_cameraLayer addSublayer:frameLayer];
    CGImageRelease(cameraFrame);
}

@end
