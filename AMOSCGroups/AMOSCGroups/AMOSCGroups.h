//
//  AMOSCGroups.h
//  AMOSCGroups
//
//  Created by 王为 on 12/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#define AM_OSC_SRV_STARTED_NOTIFICATION @"AM_OSC_SRV_STARTED_NOTIFICATION"
#define AM_OSC_SRV_STOPPED_NOTIFICATION @"AM_OSC_SRV_STOPPED_NOTIFICATION"


@interface AMOSCGroups : NSObject

+(id)sharedInstance;

-(NSViewController*)getOSCPrefUI;

-(BOOL)startOSCGroupServer;
-(void)stopOSCGroupServer;

-(BOOL)startOSCGroupClient;
-(void)stopOSCGroupClient;

-(BOOL)isOSCGroupServerStarted;
-(BOOL)isOSCGroupClientStarted;


@end
