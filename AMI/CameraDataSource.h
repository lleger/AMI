//
//  CameraDataSource.h
//  AMI
//
//  Created by Logan Leger on 4/23/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraDelegate.h"

@protocol CameraDataSource <NSObject>

- (void)startStreaming;
- (void)stopStreaming;
- (void)setDelegate:(id<CameraDelegate>)delegate;

@end
