//
//  CameraHandler.h
//  AMI
//
//  Created by Logan Leger on 4/23/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "CameraDataSource.h"
#import "CameraDelegate.h"

@interface CameraHandler : NSObject <CameraDataSource>

@property (nonatomic, weak) id<CameraDelegate> delegate;
@property (nonatomic, retain) AFHTTPClient *cameraClient;

@end
