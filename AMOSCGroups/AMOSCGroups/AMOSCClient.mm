//
//  AMOSCClient.m
//  AMOSCGroups
//
//  Created by 王为 on 13/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "OscGroupClient.h"
#import "AMOSCClient.h"

@implementation AMOSCClient

-(BOOL)startOscClient
{
    const char* serverAddr = [self.serverAddr cStringUsingEncoding:NSUTF8StringEncoding];
    int serverPort = [self.serverPort intValue];
    int remotePort = [self.remotePort intValue];
    int rxPort = [self.rxPort intValue];
    int txPort = [self.txPort intValue];
    const char* userName = [self.userName cStringUsingEncoding:NSUTF8StringEncoding];
    const char* userPwd  = [self.userPwd cStringUsingEncoding:NSUTF8StringEncoding];
    const char* groupName = [self.groupName cStringUsingEncoding:NSUTF8StringEncoding];
    const char* groupPwd = [self.groupPwd cStringUsingEncoding:NSUTF8StringEncoding];
    
    RunOSCClient(serverAddr, serverPort, remotePort, rxPort, txPort, userName, userPwd, groupName, groupPwd);
    return YES;
}


-(void)stopOscClient
{
    
//kill(<#pid_t#>, SIGINT)
}

@end
