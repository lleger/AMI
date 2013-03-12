//
//  CameraViewController.h
//  AMI
//
//  Created by Logan Leger on 2/18/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "MotionDelegate.h"
#import "MotionDataSource.h"
#import "MotionHandler.h"
#import "TransmitDelegate.h"
#import "ArduinoTransmitHandler.h"
#import "ReceiveDelegate.h"
#import "ArduinoReceiveHandler.h"

@interface MainViewController : UIViewController <MotionDelegate, ReceiveDelegate>

@property (nonatomic, weak) IBOutlet UILabel *motionData;
@property (nonatomic, weak) IBOutlet UILabel *commandLabel;
@property (nonatomic, weak) id<MotionDataSource> motionDataSource;
@property (nonatomic, weak) id<TransmitDelegate> transmitDelegate;
@property (nonatomic, weak) id<ReceiveDataSource> receiveDataSource;

- (void)changeDirectionLabel:(Direction)command;
- (IBAction)stopPressed:(id)sender;

@end
