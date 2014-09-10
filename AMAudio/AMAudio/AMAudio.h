//
//  AMAudio.h
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    JackState_Stopped = 0,
    JackState_Started,
}JackState;

#define AM_JACK_STARTED_NOTIFICATION @"Jack started notification"
#define AM_JACK_STOPPED_NOTIFICATION @"Jack stopped notification"

#define AM_RELOAD_JACK_CHANNEL_NOTIFICATION   @"JackTrip Changed"

@interface AMAudio : NSObject

+(id)sharedInstance;

-(NSViewController*)getJackPrefUI;
-(NSViewController*)getJackRouterUI;
-(NSViewController*)getJacktripPrefUI;
-(BOOL)startJack;
-(void)stopJack;

-(BOOL)isJackStarted;

-(void)releaseResources;

@end
