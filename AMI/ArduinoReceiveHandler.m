//
//  ArduinoReceiveHandler.m
//  AMI
//
//  Created by Logan Leger on 3/11/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import "ArduinoReceiveHandler.h"

static int const kSocketPort = 9000;

@implementation ArduinoReceiveHandler

- (id)init
{
    self = [super init];
    if (self) {
        _receiveQueue = dispatch_queue_create("ArduinoReceiveQueue", NULL);
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_receiveQueue];
    }
    return self;
}

#pragma mark -
#pragma mark Receive delegate methods

- (void)startListening
{
    if (![_socket isConnected]) {
        NSError *error;
        if (![_socket acceptOnPort:kSocketPort error:&error])
        {
            NSLog(@"[ArduinoReceiveHandler] Socket error: %@", error);
        }
    }
}

- (void)stopListening
{
    if ([_socket isConnected]) {
        [_socket disconnect];
    }
}

#pragma mark -
#pragma mark GCDAsyncSocket delegate methods

- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"[ArduinoReceiveHandler] New client connected %@:%hu",
          [newSocket connectedHost], [newSocket connectedPort]);
    
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"[ArduinoReceiveHandler] Client disconnected");
    [self startListening];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    
    NSArray *sensorData = [msg componentsSeparatedByString:@"|"];
    
    [_delegate didReceiveSensorData:sensorData];
    
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

@end
