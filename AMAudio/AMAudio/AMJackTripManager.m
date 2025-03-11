//
//  AMJackTripManager.m
//  AMAudio
//
//  Created by 王 为 on 9/10/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMJackTripManager.h"
#import "AMAudio.h"
#import "AMLogger/AMLogger.h"

@implementation AMJacktripInstance

@end


@implementation AMJackTripManager

-(id)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(onJackStopped:)
         name:AM_JACK_STOPPED_NOTIFICATION
         object:nil];
    }
    
    return self;
}

-(void)onJackStopped:(NSNotification*)notification
{
    [self stopAllJacktrips];
}


-(BOOL)startJacktrip:(AMJacktripConfigs *)cfgs
{
    //NSBundle* mainBundle = [NSBundle mainBundle];
   // NSMutableString* commandline = [[NSMutableString alloc] initWithFormat:@"\"%@\"", ..[mainBundle pathForAuxiliaryExecutable:@"jacktrip"]];
    NSMutableString* commandline = [[NSMutableString alloc] initWithFormat:@"/usr/local/bin/jacktrip"];
    
    //-s or -c
    if([cfgs.role isEqualToString:@"P2P SERVER"]){
        [commandline appendFormat:@" -s"];
    }else if([cfgs.role isEqualToString:@"P2P CLIENT"]){
        [commandline appendFormat:@" -c %@", cfgs.serverAddr];
    }else if([cfgs.role isEqualToString:@"HUB SERVER"]){
        [commandline appendFormat:@" -S"];
    }else{
        [commandline appendFormat:@" -C %@", cfgs.serverAddr];
    }
    
    // RT Audio
    if([cfgs.backend isEqualToString:@"RtAudio"]){
        
        [commandline appendFormat:@" --rtaudio"];
        [commandline appendFormat:@" --srate %@",           cfgs.samplingRate];
        [commandline appendFormat:@" --bufsize %@",         cfgs.bufferSize];
        
        //![commandline appendFormat:@" --audiodevice \"%@\",\"%@\"", cfgs.inputDevice, cfgs.outputDevice];
        NSString* inputDevice   = [cfgs.inputDevice   stringByReplacingOccurrencesOfString:@"," withString:@"\\,"];
        NSString* outputDevice  = [cfgs.outputDevice  stringByReplacingOccurrencesOfString:@"," withString:@"\\,"];
        [commandline appendFormat:@" --audiodevice \"%@\",\"%@\"", inputDevice, outputDevice];
    }

    //port offset
    [commandline appendFormat:@" -o %@", cfgs.portOffset];

    //channel numbers
    //[commandline appendFormat:@" -n %@", cfgs.channelCount];
    [commandline appendFormat:@" --sendchannels %@",   cfgs.channelCount];
    [commandline appendFormat:@" --receivechannels %@", cfgs.recvCount];
    

    //-q
    //[commandline appendFormat:@" -q %@", cfgs.qBufferLen];
    [commandline appendFormat:@" -q auto"];
    
    //-r
    [commandline appendFormat:@" -r %@", cfgs.rCount];

    //-b
    [commandline appendFormat:@" -b %@", cfgs.bitrateRes];

    //-z
    if (cfgs.zerounderrun) {
        [commandline appendFormat:@" -z"];
    }

    //-l
    if (cfgs.loopback) {
        [commandline appendFormat:@" -l"];
    }

    //-j
    if (cfgs.jamlink) {
        [commandline appendFormat:@" -j"];
    }
    
    //-V
    if (cfgs.useIpv6) {
        [commandline appendFormat:@" -V"];
    }
    
    if([cfgs.role isEqualToString:@"HUB SERVER"]){
        [commandline appendFormat:@" -p %@", cfgs.hubPatch];
        
        if([cfgs.hubPatch isEqualToString:@"3"] ||
           [cfgs.hubPatch isEqualToString:@"4"])
        {
            if(cfgs.includeServer)
            {
                [commandline appendFormat:@" -i"];
            }
        }
        
        //
        if(cfgs.monoToStereo){
            [commandline appendFormat:@" -u"];
        }
    }
    
    if(![cfgs.bufStrategy isEqualToString:@"0"] &&
       ![cfgs.bufStrategy isEqualToString:@"1"])
    {
        [commandline appendFormat:@" --bufstrategy %@", cfgs.bufStrategy];
    }
    
    [commandline appendFormat:@" --udprt"];
    
    [commandline appendFormat:@" -K \"%@\"",cfgs.clientName];
    
    NSString *systemLogPath = AMLogDirectory();

    NSString* jacktripLogPath = [NSString stringWithFormat:@" > \"%@/Jacktrip_%@.log\" > \"%@/Jacktrip.log\"", systemLogPath, cfgs.clientName, systemLogPath];
    //NSString* jacktripLogPath = [NSString stringWithFormat:@" > \"%@/Jacktrip_%@.log\"", systemLogPath, cfgs.clientName];
    //old [commandline appendFormat:@" --clientname %@ %@",cfgs.clientName, jacktripLogPath];
    [commandline appendFormat:@"%@", jacktripLogPath];
    
    AMLog(kAMInfoLog, @"AMAudio", @"jack trip command line is %@", commandline);
    
    NSTask* task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash";
    task.arguments = @[@"-c", [commandline copy]];
    task.terminationHandler = ^(NSTask* t){
        [self.jackTripInstances removeObject:t];
    };
    
    [task launch];

    
    AMJacktripInstance* newInstance = [[AMJacktripInstance alloc] init];
    newInstance.jacktripTask = task;
    newInstance.portOffset = [cfgs.portOffset intValue];
    newInstance.instanceName = cfgs.clientName;
    newInstance.channelCount = [cfgs.channelCount intValue];
    
    if (self.jackTripInstances == nil){
        self.jackTripInstances = [[NSMutableArray alloc] init];
    }
    
    sleep(2);
    
    if(task.isRunning){
        [self.jackTripInstances addObject:newInstance];
        
        NSNotification* notification =
        [NSNotification notificationWithName:AM_RELOAD_JACK_CHANNEL_NOTIFICATION
                                      object:self
                                    userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }else
    {
        NSLog(@"start jacktrip failed!");
    }
    
    return YES;
}


-(void)stopAllJacktrips
{
    for (AMJacktripInstance* jacktrip in self.jackTripInstances) {
        
        pid_t pid = jacktrip.jacktripTask.processIdentifier;
        NSString* command = [NSString stringWithFormat:@"killall %d >/dev/null",
                             pid];
        
        system([command cStringUsingEncoding:NSUTF8StringEncoding]);
        jacktrip.jacktripTask = nil;
    }
    
    [self.jackTripInstances removeAllObjects];
    
    NSNotification* notification = [NSNotification notificationWithName:AM_RELOAD_JACK_CHANNEL_NOTIFICATION
                                                                 object:self
                                                               userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}



-(void)stopJacktripByName:(NSString*)instanceName
{
    AMJacktripInstance* jacktrip = nil;
    for (int i = 0; i < [self.jackTripInstances count]; i++) {
        jacktrip = self.jackTripInstances[i];
        
        if ([jacktrip.instanceName isEqualToString:instanceName]) {
            break;
        }
    }
    
    if (jacktrip != nil) {
        [jacktrip.jacktripTask terminate];
        [jacktrip.jacktripTask waitUntilExit];
        jacktrip.jacktripTask = nil;
        
        [self.jackTripInstances removeObject:jacktrip];
    }

    
    NSNotification* notification = [NSNotification notificationWithName:AM_RELOAD_JACK_CHANNEL_NOTIFICATION
                                                                 object:self
                                                               userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
