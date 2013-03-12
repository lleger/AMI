//
//  ReceiveDelegate.h
//  AMI
//
//  Created by Logan Leger on 3/11/13.
//  Copyright (c) 2013 Logan Leger. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReceiveDataSource <NSObject>

- (void)startListening;
- (void)stopListening;

@end
