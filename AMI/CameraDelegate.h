//
//  CameraDelegate.h
//  AMI
//
//  Created by Logan Leger on 4/23/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CameraDelegate <NSObject>

- (void)didReceiveCameraData:(NSData *)cameraData;

@end
