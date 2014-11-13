//
//  AMOSCGroupClientViewController.m
//  AMOSCGroups
//
//  Created by wangwei on 13/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMOSCGroupClientViewController.h"
#import "AMOSCClient.h"

@interface AMOSCGroupClientViewController ()

@end

@implementation AMOSCGroupClientViewController
{
    AMOSCClient* _oscClient;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    _oscClient = [[AMOSCClient alloc] init];
    
    _oscClient.serverAddr = @"192.168.1.102";
    _oscClient.serverPort = @"22242";
    _oscClient.remotePort = @"22243";
    _oscClient.txPort = @"22244";
    _oscClient.rxPort = @"22245";
    _oscClient.userName = @"www";
    _oscClient.userPwd = @"www";
    _oscClient.groupName = @"fff";
    _oscClient.groupPwd = @"dd";

}


- (IBAction)starttest:(id)sender {
    
    [_oscClient startOscClient];
}

@end
