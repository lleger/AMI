//
//  MotionHandler.h
//  AMI
//
//  Created by Logan Leger on 3/10/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MotionManager.h"
#import "MotionDelegate.h"
#import "MotionDataSource.h"
#import "Direction.h"

@interface MotionHandler : NSObject <MotionDataSource>

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) NSOperationQueue *updateQueue;
@property (nonatomic, weak) id<MotionDelegate> delegate;
@property (nonatomic, assign) Direction currentDirection;

@end
