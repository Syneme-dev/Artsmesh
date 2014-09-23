//
//  AMJackConfigs.m
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMJackConfigs.h"
#import "AMPreferenceManager/AMPreferenceManager.h"

@implementation AMJackConfigs

-(NSString*)formatCommandLine
{
    char stringa[512];
	memset(stringa, 0, 512);
    
    SInt32 major;
    SInt32 minor;
    Gestalt(gestaltSystemVersionMajor, &major);
    Gestalt(gestaltSystemVersionMinor, &minor);
    
    if (major == 10 && minor >= 5) {
#if defined(__i386__)
        strcpy(stringa,"/usr/local/bin/jackdmp -R");
#elif defined(__x86_64__)
        strcpy(stringa,"/usr/local/bin/jackdmp -R");
#elif defined(__ppc__)
        strcpy(stringa, "arch -ppc /usr/local/bin/jackdmp -R");
#elif defined(__ppc64__)
        strcpy(stringa,"/usr/local/bin/jackdmp -R");
#endif
    }else{
        strcpy(stringa,"/usr/local/bin/jackdmp -R");
    }
    
    if (self.verboseLoggingForDebugPurpose) {
        strcpy(stringa," -v");
    }
    
    if (self.activeMIDI) {
        strcat(stringa, " -X coremidi ");
    }
    
    strcat(stringa, " -d ");
    strcat(stringa, [self.driver cStringUsingEncoding:NSUTF8StringEncoding]);
    
    strcat(stringa, " -r ");
    NSString* sampleRateStr = [NSString stringWithFormat:@"%d", self.sampleRate];
    strcat(stringa, [sampleRateStr cStringUsingEncoding:NSUTF8StringEncoding]);
    
    strcat(stringa, " -p ");
    NSString* bufferSizeStr = [NSString stringWithFormat:@"%d", self.bufferSize];
    strcat(stringa, [bufferSizeStr cStringUsingEncoding:NSUTF8StringEncoding]);
    
    strcat(stringa, " -o ");
    NSString* outchans = [NSString stringWithFormat:@"%d", self.outChansCount];
    strcat(stringa, [outchans cStringUsingEncoding:NSUTF8StringEncoding]);
    
    strcat(stringa, " -i ");
    NSString* inchans = [NSString stringWithFormat:@"%d", self.inChansCount];
    strcat(stringa, [inchans cStringUsingEncoding:NSUTF8StringEncoding]);
    
    
    if ([self.inputDevUID isEqualToString:self.outputDevUID]) {
        strcat(stringa, " -d ");
        strcat(stringa, "\"");
        strcat(stringa, [self.inputDevUID cStringUsingEncoding:NSUTF8StringEncoding]);
        strcat(stringa, "\"");
    } else {
        strcat(stringa, " -C ");
        strcat(stringa, "\"");
        strcat(stringa, [self.inputDevUID cStringUsingEncoding:NSUTF8StringEncoding]);
        strcat(stringa, "\"");
        strcat(stringa, " -P ");
        strcat(stringa, "\"");
        strcat(stringa, [self.outputDevUID  cStringUsingEncoding:NSUTF8StringEncoding]);
        strcat(stringa, "\"");
    }
    
    if (self.hogMode) {
        strcat(stringa, " -H ");
    }
    
    if (self.clockDriftCompensation) {
        strcat(stringa, " -s ");
    }
    
    if (self.systemPortMonitoring) {
        strcat(stringa, " -m ");
    }
    
    strcat(stringa, " >/dev/null 2>&1");
    
    NSString* commandLine = [NSString stringWithFormat:@"%s", stringa];
    return commandLine;
}

-(void)archiveConfigs
{
    
}

+(id)archivedJackConfig;
{
    AMJackConfigs* config = [[AMJackConfigs alloc] init];
    NSUserDefaults* defaults = [AMPreferenceManager standardUserDefaults];
    config.driver = @"coreaudio";
    config.inputDevUID = [defaults stringForKey:Preference_Jack_InputDevice];
    config.outputDevUID = [defaults stringForKey:Preference_Jack_OutputDevice];
    config.sampleRate  = [[defaults stringForKey:Preference_Jack_SampleRate] intValue];
    config.bufferSize = [[defaults stringForKey:Preference_Jack_BufferSize] intValue];
    config.inChansCount = [[defaults stringForKey:Preference_Jack_InterfaceInChans] intValue];
    config.outChansCount = [[defaults stringForKey:Preference_Jack_InterfaceOutChanns] intValue];
    config.hogMode = [[defaults stringForKey:Preference_Jack_HogMode] boolValue];
    config.clockDriftCompensation = [[defaults stringForKey:Preference_Jack_ClockDriftComp] boolValue];
    config.systemPortMonitoring= [[defaults stringForKey:Preference_Jack_PortMoniting] boolValue];
    config.activeMIDI = [[defaults stringForKey:Preference_Jack_ActiveMIDI] boolValue];

    return config;
}

@end
