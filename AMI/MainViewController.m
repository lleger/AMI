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

static NSString *const kSocketHost                   = @"192.168.1.99";
static int       const kSocketPort                   = 80;
static float     const kUpdateInterval               = 0.1;
static float     const kRotationThreshold            = 1.0;
static float     const kAttitudeRollForwardThreshold = 1.0;
static float     const kAttitudeRollReverseThreshold = 2.0;
static float     const kAttitudePitchRightThreshold  = -0.1;
static float     const kAttitudePitchLeftThreshold   = 0.0;

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err;
    if (![_socket connectToHost:kSocketHost onPort:kSocketPort error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"Socket error: %@", err);
    }
	// Do any additional setup after loading the view, typically from a nib.
    
    MotionHandler *motionHandler = [[MotionHandler alloc] init];
    _dataSource = motionHandler;
    [motionHandler setDelegate:self];
    
//    FIXME:
//    This NSLog is here because everything breaks without it.
//    Yes, this is the most important NSLog EVER. I think it's
//    a bug in ARC, or I'm missing something in my code, but
//    I'll have to come back to this. For now, it's staying put.
    NSLog(@"dataSource: %@", _dataSource);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSError *err;
    if (![_socket isConnected]) {
        if (![_socket connectToHost:kSocketHost onPort:kSocketPort error:&err]) // Asynchronous!
        {
            // If there was an error, it's likely something like "already connected" or "no delegate set"
            NSLog(@"Socket error: %@", err);
        }
    }
    
    GCDAsyncSocket *listenSocket;
    listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    if (![listenSocket acceptOnPort:9003 error:&error])
    {
        NSLog(@"I goofed: %@", error);
    }
    
    [_dataSource startUpdatingMotionData];
}

- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"New client connected %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

//- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
//{
//    NSLog(@"Client disconnected");
//}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    NSArray *sensorData = [msg componentsSeparatedByString:@"|"];
    NSLog(@"Data received from client %@:%hu: \n", [sock connectedHost], [sock connectedPort]);
    NSLog(@"Status: %@ \n", sensorData[0] ? @"OK" : @"Error");
    NSLog(@"Temperature: %i F \n", [sensorData[2] integerValue]);
    NSLog(@"Humidity: %i", [sensorData[1] integerValue]);
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_dataSource stopUpdatingMotionData];
}

- (void)changeDirection:(Direction)command
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

- (void)sendCommandToArduino:(Direction)command
{
    NSString *commandString;
    
    switch (command) {
        case DirectionForward:
            commandString = @"F";
            break;
            
        case DirectionReverse:
            commandString = @"B";
            break;
            
        case DirectionLeft:
            commandString = @"L";
            break;
            
        case DirectionRight:
            commandString = @"R";
            break;
            
        case DirectionStop:
            commandString = @"S";
            
        default:
            break;
    }
    
    commandString = [commandString stringByAppendingString:@"\n"];
    
    NSLog(@"Send command to arduino: %@", commandString);
    
    if ([_socket isConnected]) {
        [_socket writeData:[commandString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:command];
    } else {
        NSError *err;
        if (![_socket connectToHost:kSocketHost onPort:kSocketPort error:&err]) // Asynchronous!
        {
            // If there was an error, it's likely something like "already connected" or "no delegate set"
            NSLog(@"Socket error: %@", err);
        }
    }
}

- (IBAction)stopPressed:(id)sender
{
    [self changeDirection:DirectionStop];
    [self sendCommandToArduino:DirectionStop];
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

#pragma mark -
#pragma Motion delegate methods

- (void)didUpdateDirection:(Direction)direction
{
    [self changeDirection:direction];
    [self sendCommandToArduino:direction];
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
