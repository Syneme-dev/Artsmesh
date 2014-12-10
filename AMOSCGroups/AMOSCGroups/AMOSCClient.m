//
//  AMOSCClient.m
//  AMOSCGroups
//
//  Created by 王为 on 13/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMOSCClient.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"
#import "AMLogger/AMLogger.h"
#import "AMOSCMonitor.h"

@interface AMOSCClient()<AMOSCMonitorDelegate>
@end


@implementation AMOSCClient
{
    NSTask* _task;
    AMOSCMonitor *_oscMonitor;
    dispatch_queue_t _monitor_queue;
}

-(BOOL)startOscClient
{
    int m = system("killall -0 OscGroupClient >/dev/null");
    if (m != 0) {
        //Start Monitor
        _oscMonitor = [AMOSCMonitor monitorWithPort:[self.monitorPort intValue]];
        _oscMonitor.delegate = self;
        
        _monitor_queue = dispatch_queue_create("osc monitor thread", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        dispatch_async(_monitor_queue, ^{
            [_oscMonitor startListening];
        });
        
        //Launch OSCGroupClient
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSMutableString* commandline = [[NSMutableString alloc] initWithFormat:@"\"%@\"", [mainBundle pathForAuxiliaryExecutable:@"OscGroupClient"]];
        
        [commandline appendFormat:@" %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@",
         self.serverAddr, self.serverPort,
         self.remotePort, self.txPort,
         self.rxPort, self.userName,
         self.userPwd, self.groupName,
         self.groupPwd, self.monitorAddr,
         self.monitorPort];
        
        [_task terminate];
        _task = [[NSTask alloc] init];
        _task.launchPath = @"/bin/bash";
        _task.arguments = @[@"-c", [commandline copy]];
        
        //AMLog(kAMInfoLog, @"AMOscGroups", commandline);
        NSLog(@"start osc client command is : %@", commandline);
        
        [_task launch];
        
        return YES;
    }else{
        
        return  YES;
    }
}


-(void)stopOscClient
{
    [_oscMonitor stopListening];
    _oscMonitor = nil;
    
    [_task terminate];
    _task = nil;
}

-(void)receivedOscMsg:(NSData*)data
{
    NSLog(@"reveive osc messages, length:%lu", (unsigned long)[data length]);
}

-(void)parsedOscMsg:(NSString *)msg withParameters:(NSArray *)params
{
    NSLog(@"oscmessage receiced: %@", msg);
}

@end
