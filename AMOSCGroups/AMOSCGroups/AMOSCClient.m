//
//  AMOSCClient.m
//  AMOSCGroups
//
//  Created by 王为 on 13/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMOSCClient.h"

@implementation AMOSCClient
{
    NSTask* _task;
}

-(BOOL)startOscClient
{
    if (_task) {
        return YES;
    }
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSMutableString* commandline = [[NSMutableString alloc] initWithFormat:@"\"%@\"", [mainBundle pathForAuxiliaryExecutable:@"OscGroupClient"]];
    
    [commandline appendFormat:@" %@ %@ %@ %@ %@ %@ %@ %@ %@",
     self.serverAddr, self.serverPort,
     self.remotePort, self.txPort,
     self.remotePort, self.userName,
     self.userPwd, self.groupName,
     self.groupPwd];
    
    _task = [[NSTask alloc] init];
    _task.launchPath = @"/bin/bash";
    _task.arguments = @[@"-c", [commandline copy]];
    
    [_task launch];

    return YES;
}


-(void)stopOscClient
{
    [_task terminate];
    _task = nil;
}

@end
