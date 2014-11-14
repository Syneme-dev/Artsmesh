//
//  AMOSCGroupClientViewController.m
//  AMOSCGroups
//
//  Created by wangwei on 13/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMOSCGroupClientViewController.h"
#import "AMOSCClient.h"
#import "AMPreferenceManager/AMPreferenceManager.h"

@interface AMOSCGroupClientViewController ()<AMOSCClientDelegate>
@property (unsafe_unretained) IBOutlet NSTextView *oscLogView;

@end

@implementation AMOSCGroupClientViewController
{
    AMOSCClient* _oscClient;
    NSMutableArray* _oscMessageLog;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    _oscClient = [[AMOSCClient alloc] init];
    
    NSString* oscServerAddr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_ServerAddr];
    NSString* oscServerPort = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_ServerPort];
    NSString* oscRemotePort = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_RemotePort];
    NSString* oscTxPort = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_TxPort];
    NSString* oscRxPort = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_RxPort];
    NSString* oscUserName = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_UserName];
    NSString* oscUserPwd = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_UserPwd];
    NSString* oscGroupName = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_GroupName];
    NSString* oscGroupPwd = [[AMPreferenceManager standardUserDefaults ] stringForKey:Preference_OSC_Client_GroupPwd];
    NSString* oscMonitorAddr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_MonitorAddr];
    NSString* oscMonitorPort = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_MonitorPort];
    
    
    _oscClient.serverAddr = oscServerAddr;
    _oscClient.serverPort = oscServerPort;
    _oscClient.remotePort = oscRemotePort;
    _oscClient.txPort = oscTxPort;
    _oscClient.rxPort = oscRxPort;
    _oscClient.userName = oscUserName;
    _oscClient.userPwd = oscUserPwd;
    _oscClient.groupName = oscGroupName;
    _oscClient.groupPwd = oscGroupPwd;
    _oscClient.monitorAddr = oscMonitorAddr;
    _oscClient.monitorPort = oscMonitorPort;
    _oscClient.delegate = self;
    
    _oscMessageLog = [[NSMutableArray alloc] init];

}


- (IBAction)starttest:(id)sender {
    
    [_oscClient startOscClient];
}

-(void)oscMessageRecieved:(NSString *)content{
    
    NSString* oscLog = [NSString stringWithFormat:@"Received OSC Message:%@\n\n", content];
    [[[self.oscLogView textStorage] mutableString] appendString:oscLog];
    //self.logTextView.textStorage.foregroundColor = [NSColor lightGrayColor];
    [self.oscLogView setNeedsDisplay:YES];
    
}


-(void)oscMessageSent:(NSString *)content
{
    NSString* oscLog = [NSString stringWithFormat:@"Sent OSC Message: %@\n\n", content];
    [[[self.oscLogView textStorage] mutableString] appendString:oscLog];
    [self.oscLogView setNeedsDisplay:YES];
}

@end
