//
//  MotionDataSource.h
//  AMI
//
//  Created by Logan Leger on 3/10/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MotionDelegate.h"

@protocol MotionDataSource <NSObject>

- (void)startUpdatingMotionData;
- (void)stopUpdatingMotionData;
- (void)setDelegate:(id<MotionDelegate>)delegate;

@end
