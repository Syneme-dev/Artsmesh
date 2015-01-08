//
//  AMOSCGroups.h
//  AMOSCGroups
//
//  Created by 王为 on 12/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "AMOSCDefine.h"

@interface AMOSCGroups : NSObject

+(id)sharedInstance;

-(NSViewController*)getOSCPrefUI;
-(NSViewController*)getOSCMonitorUI;
-(void)startOSCGroupServer;
-(void)stopOSCGroupServer;

-(void)startOSCGroupClient:(NSString *)serverAddr;
-(void)stopOSCGroupClient;
-(void)setOSCMessageSearchFilterString:(NSString*)filterStr;

-(void)broadcastMessage:(NSString *)message  params:(NSArray *)params;

-(BOOL)isOSCGroupServerStarted;
-(BOOL)isOSCGroupClientStarted;


@end
