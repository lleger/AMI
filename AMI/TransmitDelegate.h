//
//  SocketDelegate.h
//  AMI
//
//  Created by Logan Leger on 3/11/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Direction.h"

@protocol TransmitDelegate <NSObject>

- (void)connectToArduino;
- (void)disconnectFromArduino;
- (void)writeDirectionCommand:(Direction)command;
- (void)writePowerCommand;
- (void)writeBladeCommand;

@end
