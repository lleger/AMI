//
//  CameraHandler.m
//  AMI
//
//  Created by Logan Leger on 4/23/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import "CameraHandler.h"

static NSString *const kCameraUrl = @"http://192.168.1.126:81/snapshot.cgi?user=admin&pwd=&resolution=32";

@implementation CameraHandler

- (id)init
{
    self = [super init];
    if (self) {
        _cameraClient = [[AFHTTPClient alloc] init];
    }
    return self;
}

- (void)scheduleRecurringRequests
{
    __weak typeof(self) weakSelf = self;
    
    AFHTTPRequestOperation *cameraOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kCameraUrl]]];
    [cameraOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf.delegate didReceiveCameraData:responseObject];
        [weakSelf scheduleRecurringRequests];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[CameraHandler] Error occured %@", error);
    }];
    [cameraOperation start];
}

#pragma mark -
#pragma mark Camera delegate methods

- (void)startStreaming
{
    [self scheduleRecurringRequests];
}

- (void)stopStreaming
{
    [_cameraClient cancelAllHTTPOperationsWithMethod:nil path:nil];
}

@end
