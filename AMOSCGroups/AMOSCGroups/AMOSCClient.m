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
#import "AMOSCForwarder.h"
#import "AMOSCDefine.h"

@interface AMOSCClient()<AMOSCMonitorDelegate>
@end


@implementation AMOSCClient
{
    NSTask* _task;
    AMOSCMonitor *_oscMonitor;
    AMOSCForwarder *_oscForwarder;
    dispatch_queue_t _monitor_queue;
}

-(instancetype)init
{
    if (self = [super init]) {
        _monitor_queue = dispatch_queue_create("osc monitor thread", DISPATCH_QUEUE_PRIORITY_DEFAULT);
//        _oscMonitor = [AMOSCMonitor monitorWithPort:[self.monitorPort intValue]];
//        _oscMonitor.delegate = self;
        
        _oscForwarder = [[AMOSCForwarder alloc] init];
    }
    
    return self;
}

-(BOOL)startOscClient
{
    int m = system("killall -0 OscGroupClient >/dev/null");
    if (m != 0) {
        //Start Monitor
        _oscMonitor = [AMOSCMonitor monitorWithPort:[self.monitorPort intValue]];
        _oscMonitor.delegate = self;
        dispatch_async(_monitor_queue, ^{
            [[AMOSCMonitor shareMonitor] startListening];
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
        
       // NSString *systemLogPath = AMLogDirectory();
      //  [commandline appendFormat:@"%@ > %@/OSC_Client.log", commandline, systemLogPath];
        
        [_task terminate];
        _task = [[NSTask alloc] init];
        _task.launchPath = @"/bin/bash";
        _task.arguments = @[@"-c", [commandline copy]];
        
        AMLog(kAMInfoLog, @"AMOscGroups", commandline);
        //NSLog(@"start osc client command is : %@", commandline);
        
        [_task launch];
        
        return YES;
    }else{
        
        return  YES;
    }
}


-(void)stopOscClient
{
    //dispatch_async(_monitor_queue, ^{
    //    [_oscMonitor stopListening];
    //});
    
    AMOSCMonitor *monitor = [AMOSCMonitor shareMonitor ];
    [monitor stopListening];
    
    [_task terminate];
    _task = nil;
    
    system("killall OscGroupClient >/dev/null");
}


-(void)receivedOscMsg:(NSData*)data
{
    //[_oscForwarder forwardMessage:data];
    // NSLog(@"reveive osc messages, length:%lu", (unsigned long)[data length]);
}

-(void)parsedOscMsg:(NSString *)msg withParameters:(NSArray *)params
{
   // NSLog(@"oscmessage receiced: %@", msg);
    if ([self.delegate respondsToSelector:@selector(oscMsgComming:parameters:)]){
        [self.delegate oscMsgComming:msg parameters:params];
        
        if ([msg isEqualTo:@"AM_OSC_TIMER_START"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:AM_OSC_NOTIFICATION
                                                                object:self
                                                              userInfo:@{ AM_OSC_EVENT_TYPE : AM_OSC_TIMER_START }];
        }else if([msg isEqualTo:@"AM_OSC_TIMER_STOP"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:AM_OSC_NOTIFICATION
                                                                object:self
                                                              userInfo:@{ AM_OSC_EVENT_TYPE : AM_OSC_TIMER_STOP }];
        }
    }
}

@end
