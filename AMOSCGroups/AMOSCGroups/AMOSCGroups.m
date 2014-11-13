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

@implementation AMOSCGroups
{
    AMOSCPrefViewController* _oscPrefController;
    AMOSCGroupClientViewController* _oscClientController;
    AMOSCClient* _oscClient;
    
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
    }else{
        NSNotification* notification = [[NSNotification alloc]
                                        initWithName: AM_OSC_SRV_STARTED_NOTIFICATION
                                        object:nil
                                        userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
         _isOSCServerStarted = YES;
        return NO;
    }
}


-(void)stopOSCGroupServer
{
     _isOSCServerStarted = NO;
    [_serverTask terminate];
    _serverTask = nil;
    
    system("killall OscGroupServer >/dev/null");
    NSNotification* notification = [[NSNotification alloc]
                                    initWithName: AM_OSC_SRV_STOPPED_NOTIFICATION
                                    object:nil
                                    userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    AMLog(kAMInfoLog, @"AMOSCGroup", @"OSCGroupServer is stopped!");
}

-(BOOL)startOSCGroupClient{
    
    _oscClient = [[AMOSCClient alloc] init];
    
    _oscClient.serverAddr = @"localhost";
    _oscClient.serverPort = @"22242";
    _oscClient.remotePort = @"22243";
    _oscClient.txPort = @"22244";
    _oscClient.rxPort = @"22245";
    _oscClient.userName = @"www";
    _oscClient.userPwd = @"wwwp";
    _oscClient.groupName = @"ggg";
    _oscClient.groupPwd = @"gggp";
    [_oscClient startOscClient];
    

    return NO;
}

-(void)stopOSCGroupClient{
    
}

-(BOOL)isOSCGroupServerStarted{
    return _isOSCServerStarted;
}

-(BOOL)isOSCGroupClientStarted{
    return NO;
}


@end
