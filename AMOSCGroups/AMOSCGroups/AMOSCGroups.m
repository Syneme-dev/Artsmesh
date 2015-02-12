//
//  AMOSCGroups.m
//  AMOSCGroups
//
//  Created by 王为 on 12/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMOSCGroups.h"
#import "AMLogger/AMLogger.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMOSCClient.h"
#import "AMOSCGroupMessageMonitorController.h"
#import "AMOSCForwarder.h"

@implementation AMOSCGroups
{
    AMOSCClient* _oscClient;
    AMOSCGroupMessageMonitorController* _oscMonitorController;
    
    BOOL _isOSCServerStarted;
    
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


-(NSViewController*)getOSCMonitorUI
{
    if (_oscMonitorController == nil) {
        
        NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.OSCGroupFramework"];
        _oscMonitorController = [[AMOSCGroupMessageMonitorController alloc] initWithNibName:@"AMOSCGroupMessageMonitorController" bundle:myBundle];
        
    }
    
    return _oscMonitorController;
}


-(void)checkOSCServerRunning
{
    if(_serverTask && _serverTask.isRunning){
         _isOSCServerStarted = YES;
        NSNotification* notification = [[NSNotification alloc]
                                        initWithName: AM_OSC_SRV_STARTED_NOTIFICATION
                                        object:nil
                                        userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }else{
        _isOSCServerStarted = NO;
        NSNotification* notification = [[NSNotification alloc]
                                        initWithName: AM_OSC_SRV_STOPPED_NOTIFICATION
                                        object:nil
                                        userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}


-(void)performStartOscGroupServer
{
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSMutableString* commandline = [[NSMutableString alloc] initWithFormat:@"\"%@\"", [mainBundle pathForAuxiliaryExecutable:@"OscGroupServer"]];
    
    NSString* port = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Server_Port];
    NSString* maxUsers = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Server_MaxUsers];
    NSString* maxGroups = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Server_MaxGroups];
    NSString* timeout = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Server_Timeout];
    
    NSString* logPath = [NSString stringWithFormat:@"%@/OSC_Server.log", AMLogDirectory()];
    
    [commandline appendFormat:@" -p %@ -t %@ -u %@ -g %@ -l %@", port, timeout, maxUsers, maxGroups, logPath];
    AMLog(kAMInfoLog, @"AMOSCGroup", @"osc group server command line is %@", commandline);
    
    _serverTask = [[NSTask alloc] init];
    _serverTask.launchPath = @"/bin/bash";
    _serverTask.arguments = @[@"-c", [commandline copy]];
    [_serverTask launch];
    
    [self performSelector:@selector(checkOSCServerRunning) withObject:nil afterDelay:2.0];

}


-(void)startOSCGroupServer
{
    system("killall OscGroupServer");
    [self performSelector:@selector(performStartOscGroupServer) withObject:nil afterDelay:2.0];
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


-(void)startOSCGroupClient:(NSString *)serverAddr groupName:(NSString *)groupName;
{
    
    _oscClient = [[AMOSCClient alloc] init];
    
    NSString* oscServerAddr= serverAddr;
    if (oscServerAddr == nil) {
        oscServerAddr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_ServerAddr];
    }
    NSString* oscServerPort = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_ServerPort];
    NSString* oscRemotePort = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_RemotePort];
    NSString* oscTxPort = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_TxPort];
    NSString* oscRxPort = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_RxPort];
    NSString* oscUserName = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_UserName];
    NSString* oscUserPwd = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_UserPwd];
    
    NSString* oscGroupName = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_GroupName];
    if (groupName != nil) {
        oscGroupName = groupName;
    }
    
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
    [_oscClient startOscClient];

}

-(void)stopOSCGroupClient{
    [_oscClient stopOscClient];
}

-(BOOL)isOSCGroupServerStarted{
    return _isOSCServerStarted;
}

-(BOOL)isOSCGroupClientStarted{
    return [_oscClient isStated];
}

-(void)setOSCMessageSearchFilterString:(NSString*)filterStr
{
    [_oscMonitorController setOscMessageSearchFilterString:filterStr];
}


-(void)broadcastMessage:(NSString *)message  params:(NSArray *)params
{
    if(![self isOSCGroupClientStarted] ){
        return;
    }
    
    NSString* oscTxPort = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_OSC_Client_TxPort];
    [AMOSCForwarder forwardMsg:message params:params toAddr:@"127.0.0.1" port:oscTxPort];
}

@end
