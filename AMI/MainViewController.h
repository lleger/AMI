//
//  CameraViewController.h
//  AMI
//
//  Created by Logan Leger on 2/18/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "GCDAsyncSocket.h"
#import "MotionDelegate.h"
#import "MotionDataSource.h"
#import "MotionHandler.h"

@interface MainViewController : UIViewController <GCDAsyncSocketDelegate, MotionDelegate>

@property (nonatomic, weak) IBOutlet UILabel *motionData;
@property (nonatomic, weak) IBOutlet UILabel *commandLabel;
@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, weak) id<MotionDataSource> dataSource;

- (void)changeDirection:(Direction)command;
- (void)sendCommandToArduino:(Direction)command;
- (IBAction)stopPressed:(id)sender;

@end
