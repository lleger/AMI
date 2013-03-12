//
//  ArduinoReceiveHandler.h
//  AMI
//
//  Created by Logan Leger on 3/11/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "ReceiveDelegate.h"
#import "ReceiveDataSource.h"

@interface ArduinoReceiveHandler : NSObject <GCDAsyncSocketDelegate, ReceiveDataSource>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) dispatch_queue_t receiveQueue;
@property (nonatomic, weak) id<ReceiveDelegate> delegate;

@end
