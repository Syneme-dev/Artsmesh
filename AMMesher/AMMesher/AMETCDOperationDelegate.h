//
//  AMETCDOperatationDelegate.h
//  AMMesher
//
//  Created by xujian on 4/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <AMMesher/AMETCDOperation.h>
//#import "AMETCDOperation.h"
#import "AMETCDOperation.h"

@class AMETCDOperation;

@protocol AMETCDOperationDelegate <NSObject>

-(void)AMETCDOperationDidFinished:(AMETCDOperation*)oper;

@end
