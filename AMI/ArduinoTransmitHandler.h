//
//  SocketHandler.h
//  AMI
//
//  Created by Logan Leger on 3/11/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "TransmitDelegate.h"

@interface ArduinoTransmitHandler : NSObject <GCDAsyncSocketDelegate, TransmitDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) dispatch_queue_t transmitQueue;

@end
