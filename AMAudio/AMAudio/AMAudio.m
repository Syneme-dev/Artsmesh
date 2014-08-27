//
//  AMAudio.m
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudio.h"
#import "AMAudioPrefViewController.h"
#import "AMJackConfigs.h"
#import "AMTaskLauncher/AMShellTask.h"

@interface AMAudio()

@property JackState jackState;

@end

@implementation AMAudio
{
    AMAudioPrefViewController* _prefController;
    AMJackConfigs* _configs;
    AMShellTask* _jackTask;
}

+(id)sharedInstance
{
    static AMAudio* sharedInstance = nil;
    @synchronized(self){
        if (sharedInstance == nil){
            sharedInstance = [[self alloc] privateInit];
        }
    }
    return sharedInstance;
}

-(id)init
{
    return [AMAudio sharedInstance];
}

-(id)privateInit
{
    _configs = [AMJackConfigs initWithArchiveConfig];
    
    StartNotification();
    return self;
}

-(void)dealloc
{
    
    //Are there any memory leaks?
    StopNotification();
}

-(NSViewController*)getJackPrefUI
{
    if (_prefController == nil) {
       NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.audioFramework"];
        _prefController = [[AMAudioPrefViewController alloc] initWithNibName:@"AMAudioPrefViewController" bundle:myBundle];
        _prefController.jackConfig = _configs;
    }
    
    return _prefController;
}

-(BOOL)startJack
{
    int n = system("killall -0 jackdmp >/dev/null");
    if (n != 0) {
        NSString* command =  [_configs formatCommandLine];
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
    system("killall jackdmp >/dev/null");
}

static void StartNotification()
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


static void StopNotification()
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
    AMAudio* module = [AMAudio sharedInstance];
    module.jackState = JackState_Started;
}

static void stopCallback(CFNotificationCenterRef center,
                         void*	observer,
                         CFStringRef name,
                         const void* object,
                         CFDictionaryRef userInfo)
{
    
    AMAudio* module = [AMAudio sharedInstance];
    module.jackState = JackState_Stopped;
    
// 	if (gJackRunning) {
//        id POOL = [[NSAutoreleasePool alloc] init];
//		gJackRunning = false;
//        
//		NSString *mess1 = NSLocalizedString(@"Fatal error:", nil);
//		NSString *mess2 = NSLocalizedString(@"Jack server has been stopped, JackPilot will quit.", nil);
//		NSString *mess3 = NSLocalizedString(@"Ok", nil);
//        
//		NSRunCriticalAlertPanel(mess1, mess2, mess3, nil, nil);
//		closeJack();
//        [POOL release];
//		exit(1);
//	}
}



@end
