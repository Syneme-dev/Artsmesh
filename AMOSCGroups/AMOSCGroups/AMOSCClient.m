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
#import "OSCPacket.h"

@interface AMOSCClient()<GCDAsyncUdpSocketDelegate>
@end


@implementation AMOSCClient
{
    NSTask* _task;
    GCDAsyncUdpSocket* _monitorSocket;
    dispatch_queue_t _monitorQueue;
}

-(BOOL)startOscClient
{
    int m = system("killall -0 OscGroupClient >/dev/null");
    if (m != 0) {
        //Start Monitor
        _monitorQueue = dispatch_queue_create("osc_monitor_thread", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        _monitorSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_monitorQueue];
        NSError *error = nil;
        if (![_monitorSocket bindToPort:[self.monitorPort intValue] error:&error])
        {
            AMLog(kAMErrorLog, @"AMOscGroups", @"create udp socket failed in remote mesher when request public ip. Error:%@", error);
            return NO;
        }
        
        if (![_monitorSocket beginReceiving:&error])
        {
            AMLog(kAMErrorLog, @"AMOscGroups", @"listening socket port failed in remote mesher when request public ip. Error:%@", error);
            return NO;
        }
        
        
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
    [_monitorSocket close];
    _monitorSocket = nil;
    
    [_task terminate];
    _task = nil;
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    //NSString* host = [GCDAsyncUdpSocket hostFromAddress:address];
    int port = [GCDAsyncUdpSocket portFromAddress:address];
    
    OSCMutableMessage* packet = [[OSCMutableMessage alloc] initWithData:data];
    NSLog(@"osc message:%@", packet.description);
    
    if (port == [self.remotePort intValue]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate oscMessageSent:packet.description];
        });
        
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate oscMessageRecieved:packet.description];
        });
    }
}


@end
