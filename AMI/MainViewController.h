//
//  CameraViewController.h
//  AMI
//
//  Created by Logan Leger on 2/18/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHud.h"
#import "MotionDelegate.h"
#import "MotionDataSource.h"
#import "MotionHandler.h"
#import "TransmitDelegate.h"
#import "ArduinoTransmitHandler.h"
#import "ReceiveDelegate.h"
#import "ArduinoReceiveHandler.h"
#import "CameraDelegate.h"
#import "CameraDataSource.h"
#import "CameraHandler.h"

@interface MainViewController : UIViewController <MotionDelegate, ReceiveDelegate, CameraDelegate>

@property (nonatomic, weak) IBOutlet UILabel *motionData;
@property (nonatomic, weak) IBOutlet UILabel *commandLabel;
@property (nonatomic, weak) IBOutlet UIView *sensorsView;
@property (nonatomic, weak) IBOutlet UILabel *tempLabel;
@property (nonatomic, weak) IBOutlet UILabel *humidityLabel;
@property (nonatomic, weak) IBOutlet UIButton *powerButton;
@property (nonatomic, strong) NSTimer *powerButtonDelayTimer;
@property (nonatomic, strong) CAShapeLayer *powerButtonArcLayer;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *bladeButton;
@property (nonatomic, strong) id<MotionDataSource> motionDataSource;
@property (nonatomic, strong) id<TransmitDelegate> transmitDelegate;
@property (nonatomic, strong) id<ReceiveDataSource> receiveDataSource;
@property (nonatomic, strong) id<CameraDataSource> cameraDataSource;
@property (nonatomic, strong) CALayer *cameraLayer;
@property (nonatomic, strong) CALayer *gradientLayer;

- (void)changeDirectionLabel:(Direction)command;
- (IBAction)powerPressed:(id)sender;
- (void)powerLongPressed:(id)sender;
- (IBAction)stopPressed:(id)sender;
- (IBAction)bladePressed:(id)sender;
- (void)setSensorsText:(NSDictionary *)sensorText;
- (void)showDirectionWarning:(Direction)direction animated:(BOOL)animated;
- (void)addRadialGradientToBackground;

@end
