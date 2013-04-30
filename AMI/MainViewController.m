//
//  CameraViewController.m
//  AMI
//
//  Created by Logan Leger on 2/18/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import "MainViewController.h"
#import "NSTimer+Blocks.h"
#import "UIColor+AMITheme.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

static NSString *const kPowerArcAnimationKey = @"strokeEnd";
static float const kButtonRadius = 37.5f;

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _cameraLayer = [[CALayer alloc] init];
    _cameraLayer.frame = CGRectMake(0, 0, 1024.f, 748.f);
    [self.view.layer insertSublayer:_cameraLayer atIndex:0];
    
    _gradientLayer = [[CALayer alloc] init];
    _gradientLayer.frame = CGRectMake(0, 0, 1024.f, 748.f);
    [self.view.layer insertSublayer:_gradientLayer above:_cameraLayer];
    
    CGRect sensorsViewFrame = CGRectMake(0, 0, 105.f, 30.f);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:sensorsViewFrame
                                                   byRoundingCorners:UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(5.f, 5.f)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = sensorsViewFrame;
    maskLayer.path = maskPath.CGPath;
    _sensorsView.layer.mask = maskLayer;
    
    [self setSensorsText:@{@"temp": @"--",
                           @"humidity": @"--"}];
        
    for (UIButton *button in @[_powerButton, _stopButton, _bladeButton]) {
        button.layer.borderColor = [UIColor AMIGreyColor].CGColor;
        button.layer.borderWidth = 1.f;
        button.layer.cornerRadius = kButtonRadius;
        button.backgroundColor = [UIColor whiteColor];
    }
        
    UILongPressGestureRecognizer *powerLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
    powerLongPressGestureRecognizer.minimumPressDuration = 0.1f;
    powerLongPressGestureRecognizer.allowableMovement = 50.f;
    [powerLongPressGestureRecognizer addTarget:self action:@selector(powerLongPressed:)];
    [_powerButton addGestureRecognizer:powerLongPressGestureRecognizer];
    
    [self showDirectionWarning:DirectionRight animated:YES];
    
    _transmitDelegate = [[ArduinoTransmitHandler alloc] init];
    
    _receiveDataSource = [[ArduinoReceiveHandler alloc] init];
    [_receiveDataSource setDelegate:self];
    
    _motionDataSource = [[MotionHandler alloc] init];
    [_motionDataSource setDelegate:self];
    
    _cameraDataSource = [[CameraHandler alloc] init];
    [_cameraDataSource setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [_transmitDelegate connectToArduino];

    [_receiveDataSource startListening];

    [_motionDataSource startUpdatingMotionData];
    
    [_cameraDataSource startStreaming];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_transmitDelegate writePowerCommand];
    
    [_transmitDelegate disconnectFromArduino];
    
    [_receiveDataSource stopListening];
    
    [_motionDataSource stopUpdatingMotionData];
    
    [_cameraDataSource stopStreaming];
}

#pragma mark -
#pragma mark UI methods

- (void)changeDirectionLabel:(Direction)command
{
    NSString *commandLabelText;
    
    switch (command) {
        case DirectionForward:
            commandLabelText = @"Forward";
            break;
            
        case DirectionReverse:
            commandLabelText = @"Reverse";
            break;
            
        case DirectionLeft:
            commandLabelText = @"Left";
            break;
            
        case DirectionRight:
            commandLabelText = @"Right";
            break;
            
        case DirectionStop:
            commandLabelText = @"Stop";
            break;
            
        default:
            break;
    }
    
    [_commandLabel performSelectorOnMainThread:@selector(setText:)
                                    withObject:commandLabelText waitUntilDone:YES];
}

- (IBAction)stopPressed:(id)sender
{
    [UIView animateWithDuration:0.25f animations:^{
        _stopButton.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.25f, 1.25f, 1.25f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15f animations:^{
            _stopButton.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.f, 1.f, 1.f);
        } completion:^(BOOL finished1) {
            [self changeDirectionLabel:DirectionStop];
            [_transmitDelegate writeDirectionCommand:DirectionStop];
        }];
    }];
}

- (IBAction)bladePressed:(id)sender
{
    [UIView animateWithDuration:0.25f animations:^{
        _bladeButton.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.25f, 1.25f, 1.25f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15f animations:^{
            _bladeButton.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.f, 1.f, 1.f);
        } completion:^(BOOL finished1) {
            [_transmitDelegate writeBladeCommand];
        }];
    }];
}

- (IBAction)powerPressed:(id)sender
{
    [SVProgressHUD showErrorWithStatus:@"Hold down for 2 seconds to power"];
}

- (void)powerLongPressed:(id)sender
{
    UILongPressGestureRecognizer *gestureRecognizer = (UILongPressGestureRecognizer *)sender;

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIBezierPath *powerButtonArcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(kButtonRadius, kButtonRadius)
                                                                          radius:(kButtonRadius + 4.f)
                                                                      startAngle:DEGREES_TO_RADIANS(270.f)
                                                                        endAngle:DEGREES_TO_RADIANS(-90.f)
                                                                       clockwise:YES];
        _powerButtonArcLayer = [CAShapeLayer layer];
        _powerButtonArcLayer.path = powerButtonArcPath.CGPath;
        _powerButtonArcLayer.strokeColor = [UIColor AMIRedColor].CGColor;
        _powerButtonArcLayer.fillColor = nil;
        _powerButtonArcLayer.lineWidth = 8.5f;
        _powerButtonArcLayer.lineJoin = kCALineJoinRound;
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:kPowerArcAnimationKey];
        pathAnimation.duration = 2.0f;
        pathAnimation.fromValue = @(0.f);
        pathAnimation.toValue = @(1.f);
        pathAnimation.removedOnCompletion = NO;
        CABasicAnimation *fadePath = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadePath.duration = 0.2f;
        fadePath.fromValue = @(0.f);
        fadePath.toValue = @(1.f);
        fadePath.removedOnCompletion = NO;
        fadePath.fillMode = kCAFillModeBoth;
        [_powerButtonArcLayer addAnimation:fadePath forKey:@"opacity"];
        [_powerButtonArcLayer addAnimation:pathAnimation forKey:kPowerArcAnimationKey];
        [_powerButton.layer addSublayer:_powerButtonArcLayer];
        
        _powerButtonDelayTimer = [NSTimer scheduledTimerWithTimeInterval:2.f block:^{
            [UIView animateWithDuration:0.25f animations:^{
                _powerButton.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.25f, 1.25f, 1.25f);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.15f animations:^{
                    _powerButton.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.f, 1.f, 1.f);
                } completion:^(BOOL finished1) {
                    [_transmitDelegate writePowerCommand];
                }];
            }];
            
            [_powerButtonArcLayer removeFromSuperlayer];
        } repeats:NO];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [CATransaction begin]; {
            [CATransaction setCompletionBlock:^{
                [_powerButtonArcLayer removeAllAnimations];
                [_powerButtonArcLayer removeFromSuperlayer];
                [_powerButtonDelayTimer invalidate];
            }];
            CABasicAnimation *fadePath = [CABasicAnimation animationWithKeyPath:@"opacity"];
            fadePath.duration = 0.5f;
            fadePath.fromValue = @(1.f);
            fadePath.toValue = @(0.f);
            fadePath.removedOnCompletion = NO;
            fadePath.fillMode = kCAFillModeForwards;
            [_powerButtonArcLayer addAnimation:fadePath forKey:@"opacity"];
        } [CATransaction commit];
    }
}

- (void)setSensorsText:(NSDictionary *)sensorText
{
    // TODO this is really slow
    _tempLabel.text = [NSString stringWithFormat:@"%@°", [sensorText objectForKey:@"temp"]];
    _humidityLabel.text = [NSString stringWithFormat:@"%@%%", [sensorText objectForKey:@"humidity"]];
}

- (void)showDirectionWarning:(Direction)direction animated:(BOOL)animated
{    
    CGSize viewSize = CGSizeMake(1024.f, 748.f);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 0.0);
    [_gradientLayer renderInContext:UIGraphicsGetCurrentContext()];

    CGFloat locations[] = { 0.0f, 1.0f };
    NSArray *gradientColors = [NSArray arrayWithObjects:
                               (id)[UIColor AMIRedColor].CGColor,
                               (id)[UIColor clearColor].CGColor, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, locations);
    
    CGPoint startPoint;
    CGPoint endPoint;
    
    switch (direction) {
        case DirectionLeft:
            startPoint = CGPointMake(-144.98, 374);
            endPoint = CGPointMake(-254.16, 374);
            break;
            
        case DirectionRight:
            startPoint = CGPointMake(1168.98, 374);
            endPoint = CGPointMake(1278.16, 374);
            break;
            
        case DirectionForward:
            startPoint = CGPointMake(499, -145.98);
            endPoint = CGPointMake(499, -254.56);
            break;
            
        case DirectionReverse:
            startPoint = CGPointMake(499, 893.98);
            endPoint = CGPointMake(499, 1002.56);
            break;
            
        default:
            startPoint = CGPointMake(-144.98, 374);
            endPoint = CGPointMake(-254.16, 374);
            break;
    }
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextDrawRadialGradient(currentContext, gradient,
                                startPoint, 141.94,
                                endPoint, 446.17,
                                kCGGradientDrawsBeforeStartLocation |
                                kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [_gradientLayer setContents:(id)image.CGImage];
    
    if (animated) {
        CABasicAnimation *fadeGradientAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        fadeGradientAnimation.duration = 1.25f;
        fadeGradientAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        fadeGradientAnimation.toValue = [NSValue valueWithCATransform3D:
                          CATransform3DMakeScale(1.1f, 1.1f, 1.25f)];
        fadeGradientAnimation.autoreverses = YES;
        fadeGradientAnimation.repeatCount = HUGE_VALF;
        [_gradientLayer addAnimation:fadeGradientAnimation forKey:@"transform"];
    }
}

- (void)addRadialGradientToBackground
{
    CGSize viewSize = CGSizeMake(748.f, 1024.f);
    
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 0.0);
    [_gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    
    size_t locationsCount = 2;
    CGFloat locations[2] = {0.0f, 1.0f};
    CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    CGColorSpaceRelease(colorSpace);
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGPoint center = CGPointMake(viewSize.width/2, viewSize.height/2);
    float radius = MIN(viewSize.width, viewSize.height);
    CGContextDrawRadialGradient(currentContext, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [_gradientLayer setContents:(id)image.CGImage];
}

#pragma mark -
#pragma mark Receive delegate methods

- (void)didReceiveSensorData:(NSArray *)sensorData
{
    NSLog(@"sensorData = %@", sensorData);
    
    if ([sensorData[0] integerValue] != 1) {
        NSLog(@"[MainViewController] Error from Arduino in receiving sensor data status = %@", sensorData[0]);
    } else {
        [self setSensorsText:@{@"temp": sensorData[2],
                               @"humidity": sensorData[1]}];
    }
}

#pragma mark -
#pragma mark Motion delegate methods

- (void)didUpdateDirection:(Direction)direction
{
    [self changeDirectionLabel:direction];
    [_transmitDelegate writeDirectionCommand:direction];
}

- (void)didUpdateMotionWithRotationRate:(CMRotationRate)rotationRate
                            andAttitude:(CMAttitude *)attitude
{
    NSString *motionText = [NSString stringWithFormat:
                            @"Roll: %f\n"
                            @"Pitch: %f\n"
                            @"Yaw: %f\n"
                            @"Rot rate X: %f\n"
                            @"Rot rate Y: %f\n"
                            @"Rot rate Z: %f",
                            attitude.roll,
                            attitude.pitch,
                            attitude.yaw,
                            rotationRate.x,
                            rotationRate.y,
                            rotationRate.z];
    [_motionData performSelectorOnMainThread:@selector(setText:)
                                  withObject:motionText waitUntilDone:YES];
}

#pragma mark -
#pragma mark Camera delegate methods

- (void)didReceiveCameraData:(NSData *)cameraData
{
    [_cameraLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    CALayer *frameLayer = [CALayer layer];
    frameLayer.frame = _cameraLayer.bounds;
    CFDataRef frameData = CFDataCreate(NULL, [cameraData bytes], [cameraData length]);
    CGDataProviderRef imgDataProvider;
    CGImageRef cameraFrame;
    imgDataProvider = CGDataProviderCreateWithCFData(frameData);
    CFRelease(frameData);
    cameraFrame = CGImageCreateWithJPEGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(imgDataProvider);
    [frameLayer setContents:(__bridge id)(cameraFrame)];
    [_cameraLayer addSublayer:frameLayer];
    CGImageRelease(cameraFrame);
}

@end
