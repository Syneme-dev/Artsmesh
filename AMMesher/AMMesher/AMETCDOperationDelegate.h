//
//  AMETCDOperationDelegate.h
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMETCDOperation;
@protocol AMETCDOperationDelegate <NSObject>

-(void)AMETCDOperationDidFinished:(AMETCDOperation*)oper;

@end
