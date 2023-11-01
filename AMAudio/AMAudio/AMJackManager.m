//
//  AMJackManager.m
//  AMAudio
//
//  Created by 王 为 on 9/10/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMJackManager.h"
#import "AMLogger/AMLogger.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMAudio.h"

@implementation AMJackManager
{
    NSTask* _jackTask;
}

-(id)init
{
    if (self = [super init]) {
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
        NSString* command =  [self jackLaunchingCommand];
        AMLog(kAMInfoLog, @"AMAudio", @"start jack commmand is: %@", command);
    
        _jackTask = [[NSTask alloc] init];
        _jackTask.launchPath = @"/bin/bash";
        _jackTask.arguments = @[@"-c", [command copy]];
        _jackTask.terminationHandler = ^(NSTask* t){
            
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
    AMLog(kAMInfoLog, @"AMAudio", @"Jack Server is stopped!");
    self.jackState = JackState_Stopped;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     unregisterJackStartStopNofification();
}


-(NSString *)jackLaunchingCommand
{
    NSString *driver = [[AMPreferenceManager standardUserDefaults]
                         stringForKey:Preference_Jack_Driver];
    
    NSString *inputDevUID = [[AMPreferenceManager standardUserDefaults]
                             stringForKey:Preference_Jack_InputDevice];
    
    NSString *outputDevUID = [[AMPreferenceManager standardUserDefaults]
                             stringForKey:Preference_Jack_OutputDevice];
    
    NSString *sampleRate = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Jack_SampleRate];
    
    NSString *bufferSize = [[AMPreferenceManager standardUserDefaults]
                            stringForKey:Preference_Jack_BufferSize];
    
    NSString *inChannCount = [[AMPreferenceManager standardUserDefaults]
                            stringForKey:Preference_Jack_InterfaceInChans];
    
    NSString *outChannCount = [[AMPreferenceManager standardUserDefaults]
                               stringForKey:Preference_Jack_InterfaceOutChanns];
    
    BOOL hogMode = [[AMPreferenceManager standardUserDefaults]
                      boolForKey:Preference_Jack_HogMode];
    
    BOOL clockCompensation = [[AMPreferenceManager standardUserDefaults]
                               boolForKey:Preference_Jack_ClockDriftComp];
    
    BOOL monitoring = [[AMPreferenceManager standardUserDefaults]
                               boolForKey:Preference_Jack_PortMoniting];
    
    BOOL midi =[[AMPreferenceManager standardUserDefaults]
                boolForKey:Preference_Jack_ActiveMIDI];

    
    BOOL autoConnect =[[AMPreferenceManager standardUserDefaults]
                       boolForKey:Preference_Jack_AutoConnect];
    
    char stringa[512];
    memset(stringa, 0, 512);
    
    SInt32 major;
    SInt32 minor;
    Gestalt(gestaltSystemVersionMajor, &major);
    Gestalt(gestaltSystemVersionMinor, &minor);
    
    if (major == 10 && minor >= 5) {
#if defined(__i386__)
        strcpy(stringa,"/usr/local/bin/jackd -R");
#elif defined(__x86_64__)
        strcpy(stringa,"/usr/local/bin/jackd -R");
#elif defined(__ppc__)
        strcpy(stringa, "arch -ppc /usr/local/bin/jackdmp -R");
#elif defined(__ppc64__)
        strcpy(stringa,"/usr/local/bin/jackd -R");
#endif
    }else{
        strcpy(stringa,"/usr/local/bin/jackd -v");
    }

    if (midi) {
        strcat(stringa, " -X coremidi ");
    }
    
    strcat(stringa, " -d");
    strcat(stringa, [driver cStringUsingEncoding:NSUTF8StringEncoding]);
    
    strcat(stringa, " -r");
    NSString* sampleRateStr = [NSString stringWithFormat:@"%@", sampleRate];
    strcat(stringa, [sampleRateStr cStringUsingEncoding:NSUTF8StringEncoding]);
    
    strcat(stringa, " -p");
    NSString* bufferSizeStr = [NSString stringWithFormat:@"%@", bufferSize];
    strcat(stringa, [bufferSizeStr cStringUsingEncoding:NSUTF8StringEncoding]);
   
    strcat(stringa, " -o ");
    NSString* outchans = [NSString stringWithFormat:@"%@", outChannCount];
    strcat(stringa, [outchans cStringUsingEncoding:NSUTF8StringEncoding]);
    
    strcat(stringa, " -i ");
    NSString* inchans = [NSString stringWithFormat:@"%@", inChannCount];
    strcat(stringa, [inchans cStringUsingEncoding:NSUTF8StringEncoding]);
    
    /*
    if ([inputDevUID isEqualToString:outputDevUID]) {
        strcat(stringa, " -d ");
        strcat(stringa, "\"");
        strcat(stringa, [inputDevUID cStringUsingEncoding:NSUTF8StringEncoding]);
        strcat(stringa, "\"");
    } else {
        strcat(stringa, " -C ");
        strcat(stringa, "\"");
        strcat(stringa, [inputDevUID cStringUsingEncoding:NSUTF8StringEncoding]);
        strcat(stringa, "\"");
        strcat(stringa, " -P ");
        strcat(stringa, "\"");
        strcat(stringa, [outputDevUID  cStringUsingEncoding:NSUTF8StringEncoding]);
        strcat(stringa, "\"");
    }
    
    if (hogMode) {
        strcat(stringa, " -H ");
    }
    
    if (clockCompensation) {
        strcat(stringa, " -s ");
    }
    
    if (monitoring) {
        strcat(stringa, " -m ");
    }
    */
    
    NSString *jackLog = [NSString stringWithFormat:@" > %@/Jack_Audio.log", AMLogDirectory()];
    const char *szLogPath = [jackLog cStringUsingEncoding:NSUTF8StringEncoding];
    strcat(stringa, szLogPath);
    
    NSString* commandLine = [NSString stringWithFormat:@"%s", stringa];
    return commandLine;
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
