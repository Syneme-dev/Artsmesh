//
//  AMJackTripManager.m
//  AMAudio
//
//  Created by 王 为 on 9/10/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMJackTripManager.h"
#import "AMAudio.h"

@implementation AMJacktripInstance

@end


@implementation AMJackTripManager

-(BOOL)startJacktrip:(AMJacktripConfigs *)cfgs
{
    NSMutableString* commandline = [NSMutableString stringWithFormat:@"jacktrip"];
    
    //-s or -c
    if([cfgs.role isEqualToString:@"Server"]){
        [commandline appendFormat:@" -s"];
    }else{
        [commandline appendFormat:@" -c %@", cfgs.serverAddr];
    }

    //port offset
    [commandline appendFormat:@" -o %@", cfgs.portOffset];

    //channel numbers
    [commandline appendFormat:@" -n %@", cfgs.channelCount];

    //-q
    [commandline appendFormat:@" -q %@", cfgs.qCount];

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
    
    [commandline appendFormat:@" --clientname %@", cfgs.clientName];
    NSLog(@"jack trip command line is: %@", commandline);

    AMShellTask* task = [[AMShellTask alloc] initWithCommand:commandline];
    [task launch];
    
    AMJacktripInstance* newInstance = [[AMJacktripInstance alloc] init];
    newInstance.jacktripTask = task;
    newInstance.portOffset = [cfgs.portOffset intValue];
    newInstance.instanceName = cfgs.clientName;
    
    if (self.jackTripInstances == nil){
        self.jackTripInstances = [[NSMutableArray alloc] init];
    }
    
    [self.jackTripInstances addObject:newInstance];
    
    NSNotification* notification = [NSNotification notificationWithName:AM_JACKTRIP_CHANGED_NOTIFICATION
                                                                 object:self
                                                               userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    return YES;
}

-(void)stopAllJacktrips
{
    for (AMJacktripInstance* jacktrip in self.jackTripInstances) {
        [jacktrip.jacktripTask cancel];
        jacktrip.jacktripTask = nil;
    }
    
    system("killall jacktrip >/dev/null");
}

-(void)stopJacktripByName:(NSString*)instanceName
{
    for (int i = 0; i < [self.jackTripInstances count]; i++) {
        AMJacktripInstance* jacktrip = self.jackTripInstances[i];
        
        if ([jacktrip.instanceName isEqualToString:instanceName]) {
            [jacktrip.jacktripTask cancel];
            jacktrip.jacktripTask = nil;
            
            [self.jackTripInstances removeObject:jacktrip];
            break;
        }
    }
}

@end
