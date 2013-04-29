//
//  SocketHandler.m
//  AMI
//
//  Created by Logan Leger on 3/11/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import "ArduinoTransmitHandler.h"

static NSString *const kSocketHost      = @"192.168.1.145";
static int       const kSocketPort      = 80;
static long      const kPowerCommandTag = 16;
static NSString *const kPowerCommand    = @"O";
static long      const kBladeCommandTag = 31;
static NSString *const kBladeCommand    = @"C";

@implementation ArduinoTransmitHandler

- (id)init
{
    self = [super init];
    if (self) {
        _transmitQueue = dispatch_queue_create("ArduinoTransmitQueue", NULL);
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_transmitQueue];
    }
    return self;
}

#pragma mark -
#pragma mark Transmit delegate methods

- (void)connectToArduino
{
    if (![_socket isConnected]) {
        NSError *err;
        if (![_socket connectToHost:kSocketHost onPort:kSocketPort error:&err])
        {
            NSLog(@"[ArduinoTransmitHandler] Socket error: %@", err);
        }
    }
}

- (void)disconnectFromArduino
{
    if ([_socket isConnected]) {
        [_socket disconnect];
    }
}

- (void)writeDirectionCommand:(Direction)command
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
    
    [self writeCommand:commandString withTag:command];
}

- (void)writePowerCommand
{
    [self writeCommand:kPowerCommand withTag:kPowerCommandTag];
}

- (void)writeBladeCommand
{
    [self writeCommand:kBladeCommand withTag:kBladeCommandTag];
}

- (void)writeCommand:(NSString *)command withTag:(long)tag
{
    if ([_socket isConnected]) {
        [_socket writeData:[[command stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]
               withTimeout:-1 tag:tag];
    } else {
        [self connectToArduino];
    }
}

#pragma mark -
#pragma mark GCDAsyncSocket delegate methods

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"[ArduinoTransmitHandler] Did connect to host: %@:%i", host, port);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"[ArduinoTransmitHandler] Socket disconnected with error: %@", err);
    [self connectToArduino];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"[ArduinoTransmitHandler] Did write data with tag: %li", tag);
}

@end
