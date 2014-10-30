//
//  AMJackManager.m
//  AMAudio
//
//  Created by 王 为 on 9/10/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMJackManager.h"
#import "AMLogger/AMLogger.h"

@implementation AMJackManager
{
    NSTask* _jackTask;
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
    int n = system("killall -0 jackd >/dev/null");
    int m = system("killall -0 jackdmp >/dev/null");
    if (n != 0 && m != 0) {
        NSString* command =  [self.jackCfg formatCommandLine];
        AMLog(kAMDebugLog, @"AMAudio", @"start jack commmand is: %@", command);
    
        _jackTask = [[NSTask alloc] init];
        _jackTask.launchPath = @"/bin/bash";
        _jackTask.arguments = @[@"-c", [command copy]];
        _jackTask.terminationHandler = ^(NSTask* t){
            AMLog(kAMDebugLog, @"AMAudio", @"Jack service is stopped!");
        };
        
        [_jackTask launch];

         return YES;
     }else{
         NSNotification* notification = [[NSNotification alloc]
                                         initWithName: AM_JACK_STARTED_NOTIFICATION
                                         object:nil
                                         userInfo:nil];
         [[NSNotificationCenter defaultCenter] postNotification:notification];
         return NO;
     }
}

-(void)stopJack
{
    [_jackTask terminate];
    _jackTask = nil;
    
    system("killall jackd >/dev/null");
    system("killall jackdmp >/dev/null");
    
    NSNotification* notification = [[NSNotification alloc]
                                    initWithName: AM_JACK_STOPPED_NOTIFICATION
                                    object:nil
                                    userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)jackStarted:(NSNotification*)notification
{
    AMLog(kAMInfoLog, @"AMAudio", @"Jack Server is started!");
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
                                    initWithName: AM_JACK_STOPPED_NOTIFICATION
                                    object:nil
                                    userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


@end
