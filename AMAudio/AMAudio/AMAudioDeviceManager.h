//
//  AMAudioDeviceManager.h
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMAudioDevice.h"

@interface AMAudioDeviceManager : NSObject

-(AMAudioDevice*)defaultInputDevice;
-(AMAudioDevice*)defaultOutputDevice;

-(NSArray*)inputDevices;
-(NSArray*)outputDevices;

-(void)loadDevices;

@end
