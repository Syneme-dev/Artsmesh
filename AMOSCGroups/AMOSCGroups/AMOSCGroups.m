//
//  AMOSCGroups.m
//  AMOSCGroups
//
//  Created by 王为 on 12/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMOSCGroups.h"
#import "AMOSCPrefViewController.h"
#import "AMLogger/AMLogger.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMOSCClient.h"
#import "AMOSCGroupClientViewController.h"
#import "AMOSCGroupMessageMonitorController.h"

@implementation AMOSCGroups
{
    AMOSCClient* _oscClient;
    
    AMOSCPrefViewController* _oscPrefController;
    AMOSCGroupClientViewController* _oscClientController;
    AMOSCGroupMessageMonitorController* _oscMonitorController;
    
    BOOL _isOSCServerStarted;
    BOOL _isOSCClientStarted;
    
    NSTask* _serverTask;
    NSTask* _clientTask;
}

+(id)sharedInstance
{
    static AMOSCGroups* sharedInstance = nil;
    @synchronized(self){
        if (sharedInstance == nil){
            sharedInstance = [[self alloc] privateInit];
        }
    }
    return sharedInstance;
}

-(id)init
{
    return [AMOSCGroups sharedInstance];
}

-(id)privateInit
{
    system("killall OscGroupClient >/dev/null");
    return self;
}

-(NSViewController*)getOSCPrefUI
{
    if (_oscPrefController == nil) {
        NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.OSCGroupFramework"];
        _oscPrefController = [[AMOSCPrefViewController alloc] initWithNibName:@"AMOSCPrefViewController" bundle:myBundle];
    }
    
    return _oscPrefController;
}

-(NSViewController*)getOSCClientUI
{
    if (_oscClientController == nil) {
        
        NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.OSCGroupFramework"];
        _oscClientController = [[AMOSCGroupClientViewController alloc] initWithNibName:@"AMOSCGroupClientViewController" bundle:myBundle];
        
    }
    
    return _oscClientController;
}

-(NSViewController*)getOSCMonitorUI
{
    if (_oscMonitorController == nil) {
        
        NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.OSCGroupFramework"];
        _oscMonitorController = [[AMOSCGroupMessageMonitorController alloc] initWithNibName:@"AMOSCGroupMessageMonitorController" bundle:myBundle];
        
    }
    
    return _oscMonitorController;
}

-(BOOL)startOSCGroupServer;
{
    int m = system("killall -0 OscGroupServer >/dev/null");
    if (m != 0) {
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSMutableString* commandline = [[NSMutableString alloc] initWithFormat:@"\"%@\"", [mainBundle pathForAuxiliaryExecutable:@"OscGroupServer"]];
        
        NSString* port = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Server_Port];
        NSString* maxUsers = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Server_MaxUsers];
        NSString* maxGroups = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Server_MaxGroups];
        NSString* timeout = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Server_Timeout];
        
        NSString* logPath = [NSString stringWithFormat:@"%@/Library/Logs/Artsmesh/OscSrv.log", NSHomeDirectory()];
        
        [commandline appendFormat:@" -p %@ -t %@ -u %@ -g %@ -l %@", port, timeout, maxUsers, maxGroups, logPath];
        AMLog(kAMInfoLog, @"AMOSCGroup", @"osc group server command line is %@", commandline);
        
        _serverTask = [[NSTask alloc] init];
        _serverTask.launchPath = @"/bin/bash";
        _serverTask.arguments = @[@"-c", [commandline copy]];
        [_serverTask launch];
        
        _isOSCServerStarted = YES;
        
        return YES;
    }
    
    return NO;
//    else{
//        NSNotification* notification = [[NSNotification alloc]
//                                        initWithName: AM_OSC_SRV_STARTED_NOTIFICATION
//                                        object:nil
//                                        userInfo:nil];
//        [[NSNotificationCenter defaultCenter] postNotification:notification];
//         _isOSCServerStarted = YES;
//        return NO;
//    }
}


-(void)stopOSCGroupServer
{
    _isOSCServerStarted = NO;
    
    if (_serverTask != nil) {
        kill(_serverTask.processIdentifier, SIGINT);
        _serverTask = nil;
        
        NSNotification* notification = [[NSNotification alloc]
                                        initWithName: AM_OSC_SRV_STOPPED_NOTIFICATION
                                        object:nil
                                        userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        AMLog(kAMInfoLog, @"AMOSCGroup", @"OSCGroupServer is stopped!");
    }


}

-(BOOL)startOSCGroupClient{
    
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
    _oscClient.delegate = _oscMonitorController;

    if ([_oscClient startOscClient]){
        _isOSCClientStarted = YES;
    }
    
    return _isOSCClientStarted;
}

-(void)stopOSCGroupClient{
    [_oscClient stopOscClient];
    _isOSCClientStarted = NO;
}

-(BOOL)isOSCGroupServerStarted{
    return _isOSCServerStarted;
}

-(BOOL)isOSCGroupClientStarted{
    return _isOSCClientStarted;
}

-(void)setOSCMessageSearchFilterString:(NSString*)filterStr
{
    [_oscMonitorController setOscMessageSearchFilterString:filterStr];
}


@end
