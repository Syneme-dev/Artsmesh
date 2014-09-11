//
//  AMJackManager.m
//  AMAudio
//
//  Created by 王 为 on 9/10/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMJackManager.h"
#import "AMTaskLauncher/AMShellTask.h"


@implementation AMJackManager
{
    AMShellTask* _jackTask;
}

-(id)init
{
    if (self = [super init]) {
        self.jackCfg = [AMJackConfigs archivedJackConfig];
        registerJackStartStopNofification();
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(jackStarted:)
         name:AM_JACK_STARTED_NOTIFICATION
         object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(jackStopped:)
         name:AM_JACK_STOPPED_NOTIFICATION
         object:nil];
        
    }
    
    return self;
}

-(BOOL)startJack
{
     int n = system("killall -0 jackdmp >/dev/null");
     if (n != 0) {
         NSString* command =  [self.jackCfg formatCommandLine];
         NSLog(@"command is %@", command);
         _jackTask = [[AMShellTask alloc] initWithCommand:command];
         [_jackTask launch];
     }else{
         self.jackState = JackState_Started;
     }
    
    return YES;
}

-(void)stopJack
{
    [_jackTask cancel];
    _jackTask = nil;
    
    system("killall jackdmp >/dev/null");
}

-(void)jackStarted:(NSNotification*)notification
{
    self.jackState = JackState_Started;
}

-(void)jackStopped:(NSNotification*)notification
{
    self.jackState = JackState_Stopped;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     unregisterJackStartStopNofification();
}

static void registerJackStartStopNofification()
{
	CFStringRef ref = CFStringCreateWithCString(NULL, DefaultServerName(), kCFStringEncodingMacRoman);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(),
									NULL, startCallback, CFSTR("com.grame.jackserver.start"),
									ref, CFNotificationSuspensionBehaviorDeliverImmediately);
    
	CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(),
									NULL, stopCallback, CFSTR("com.grame.jackserver.stop"),
									ref, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFRelease(ref);
}


static void unregisterJackStartStopNofification()
{
	CFStringRef ref = CFStringCreateWithCString(NULL, DefaultServerName(), kCFStringEncodingMacRoman);
	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDistributedCenter(), NULL,
                                       CFSTR("com.grame.jackserver.start"), ref);
    
	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDistributedCenter(), NULL,
                                       CFSTR("com.grame.jackserver.stop"), ref);
	CFRelease(ref);
}


static char* DefaultServerName()
{
    char* server_name;
    if ((server_name = getenv("JACK_DEFAULT_SERVER")) == NULL)
        server_name = "default";
    return server_name;
}


static void startCallback(CFNotificationCenterRef center,
                          void*	observer,
                          CFStringRef name,
                          const void* object,
                          CFDictionaryRef userInfo)
{
    NSNotification* notification = [[NSNotification alloc]
                                    initWithName: AM_JACK_STARTED_NOTIFICATION
                                    object:nil
                                    userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
}

static void stopCallback(CFNotificationCenterRef center,
                         void*	observer,
                         CFStringRef name,
                         const void* object,
                         CFDictionaryRef userInfo)
{
    
    NSNotification* notification = [[NSNotification alloc]
                                    initWithName: AM_JACK_STOPPED_NOTIFICATION                                    object:nil
                                    userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


@end
