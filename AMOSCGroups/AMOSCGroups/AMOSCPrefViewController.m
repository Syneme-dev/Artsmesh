//
//  AMOSCPrefViewController.m
//  AMOSCGroups
//
//  Created by 王为 on 12/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMOSCPrefViewController.h"
#import "AMPreferenceManager/AMPreferenceManager.h"


@interface AMOSCPrefViewController ()
@property (weak) IBOutlet NSTextField *oscMyServerPort;
@property (weak) IBOutlet NSTextField *oscMyServerMaxUsers;
@property (weak) IBOutlet NSTextField *oscMyServerTimeout;
@property (weak) IBOutlet NSTextField *oscMyServerMaxGroups;
@property (weak) IBOutlet NSTextField *oscServerAddr;
@property (weak) IBOutlet NSTextField *oscServerPort;
@property (weak) IBOutlet NSTextField *oscClientRemotePort;
@property (weak) IBOutlet NSTextField *oscClientTxPort;
@property (weak) IBOutlet NSTextField *oscClientRxPort;
@property (weak) IBOutlet NSTextField *oscClientUserName;
@property (weak) IBOutlet NSTextField *oscClientUserPwd;
@property (weak) IBOutlet NSTextField *oscClientGroupName;
@property (weak) IBOutlet NSTextField *oscClientGroupPwd;
@property (weak) IBOutlet NSTextField *oscClientMonitorAddr;
@property (weak) IBOutlet NSTextField *oscClientMonitorPort;

@end

@implementation AMOSCPrefViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self restoreConfig:nil];
}

- (IBAction)saveConfig:(id)sender
{
    if(![self checkConfig]){
        return;
    }
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.oscMyServerPort.stringValue
     forKey:Preference_OSC_Server_Port];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.oscMyServerMaxUsers.stringValue
     forKey:Preference_OSC_Server_MaxUsers];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.oscMyServerTimeout.stringValue
     forKey:Preference_OSC_Server_Timeout];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.oscMyServerMaxGroups.stringValue
     forKey:Preference_OSC_Server_MaxGroups];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.oscServerAddr.stringValue
     forKey:Preference_OSC_Client_ServerAddr];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.oscServerPort.stringValue
     forKey:Preference_OSC_Client_ServerPort];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.oscClientRemotePort.stringValue
     forKey:Preference_OSC_Client_RemotePort];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.oscClientTxPort.stringValue
     forKey:Preference_OSC_Client_TxPort];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.oscClientRxPort.stringValue
     forKey:Preference_OSC_Client_RxPort];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.oscClientUserName.stringValue
     forKey:Preference_OSC_Client_UserName];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.oscClientUserPwd.stringValue
     forKey:Preference_OSC_Client_UserPwd];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.oscClientGroupName.stringValue
     forKey:Preference_OSC_Client_GroupName];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.oscClientGroupPwd.stringValue
     forKey:Preference_OSC_Client_GroupPwd];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.oscClientMonitorAddr
     forKey:Preference_OSC_Client_MonitorAddr];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.oscClientMonitorPort
     forKey:Preference_OSC_Client_MonitorPort];
    
}

- (IBAction)restoreConfig:(id)sender
{
    NSString* myServerPort = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_OSC_Server_Port];
    self.oscMyServerPort.stringValue = myServerPort;
    
    NSString* myServerMaxUsers = [[AMPreferenceManager standardUserDefaults]
                                  stringForKey:Preference_OSC_Server_MaxUsers];
    self.oscMyServerMaxUsers.stringValue = myServerMaxUsers;
    
    NSString* myServerMaxGroups = [[AMPreferenceManager standardUserDefaults]
                                   stringForKey:Preference_OSC_Server_MaxGroups];
    self.oscMyServerMaxGroups.stringValue = myServerMaxGroups;
    
    NSString* myServerMaxTimeout = [[AMPreferenceManager standardUserDefaults]
                                    stringForKey:Preference_OSC_Server_Timeout];
    self.oscMyServerTimeout.stringValue = myServerMaxTimeout;
    
    
    NSString* serverAddr = [[AMPreferenceManager standardUserDefaults]
                            stringForKey:Preference_OSC_Client_ServerAddr];
    self.oscServerAddr.stringValue = serverAddr;
    
    NSString* serverPort = [[AMPreferenceManager standardUserDefaults]
                            stringForKey:Preference_OSC_Client_ServerPort];
    self.oscServerPort.stringValue = serverPort;
    
    NSString* remotePort = [[AMPreferenceManager standardUserDefaults]
                            stringForKey:Preference_OSC_Client_RemotePort];
    self.oscClientRemotePort.stringValue = remotePort;
    
    NSString* txPort = [[AMPreferenceManager standardUserDefaults]
                            stringForKey:Preference_OSC_Client_TxPort];
    self.oscClientTxPort.stringValue = txPort;
    
    NSString* rxPort = [[AMPreferenceManager standardUserDefaults]
                        stringForKey:Preference_OSC_Client_RxPort];
    self.oscClientRxPort.stringValue = rxPort;
    
    NSString* username = [[AMPreferenceManager standardUserDefaults]
                        stringForKey:Preference_OSC_Client_UserName];
    self.oscClientUserName.stringValue = username;
    
    NSString* userpwd = [[AMPreferenceManager standardUserDefaults]
                          stringForKey:Preference_OSC_Client_UserPwd];
    self.oscClientUserPwd.stringValue = userpwd;

    NSString* groupname = [[AMPreferenceManager standardUserDefaults]
                         stringForKey:Preference_OSC_Client_GroupName];
    self.oscClientGroupName.stringValue = groupname;
    
    NSString* grouppwd = [[AMPreferenceManager standardUserDefaults]
                           stringForKey:Preference_OSC_Client_GroupPwd];
    self.oscClientGroupPwd.stringValue = grouppwd;
    
    NSString* monitorAddr = [[AMPreferenceManager standardUserDefaults]
                             stringForKey:Preference_OSC_Client_MonitorAddr];
    self.oscClientMonitorAddr.stringValue = monitorAddr;
    
    NSString* monitorPort = [[AMPreferenceManager standardUserDefaults]
                             stringForKey:Preference_OSC_Client_MonitorPort];
    self.oscClientMonitorPort.stringValue = monitorPort;
}


-(BOOL)checkConfig
{
    NSMutableArray* usedPorts = [[NSMutableArray alloc] init];
    
    int myServerPort = [self.oscMyServerPort.stringValue intValue];
    if(myServerPort > 65535 || myServerPort < 1025){
        return NO;
    }
    
    [usedPorts addObject:[[NSNumber alloc] initWithInt:myServerPort]];
    
    int myServerMaxUsers = [self.oscMyServerMaxUsers.stringValue intValue];
    if(myServerMaxUsers < 1 || myServerMaxUsers > 50){
        return NO;
    }
    
    int myServerTimeout = [self.oscMyServerTimeout.stringValue intValue];
    if(myServerTimeout < 30){
        
        return NO;
    }
    
    int myServerMaxGroups = [self.oscMyServerMaxGroups.stringValue intValue];
    if (myServerMaxGroups < 1 || myServerMaxUsers > 50){
        
        return NO;
    }
    
    NSString* serverAddr = self.oscServerAddr.stringValue;
    if ([serverAddr isEqualToString:@""]) {
        
        return NO;
    }
    
    int serverPort = [self.oscServerPort.stringValue intValue];
    if (serverPort < 1025 || serverPort > 65535) {
        
        return NO;
    }
    
    [usedPorts addObject:[[NSNumber alloc] initWithInt:serverPort]];
    
    int remotePort = [self.oscClientRemotePort.stringValue intValue];
    if (remotePort < 1025 || remotePort > 65535) {
        
        return NO;
    }
    
    [usedPorts addObject:[[NSNumber alloc] initWithInt:remotePort]];
    
    int txPort = [self.oscClientTxPort.stringValue intValue];
    if (txPort < 1025 || txPort > 65535) {
        
        return NO;
    }
    
    [usedPorts addObject:[[NSNumber alloc] initWithInt:txPort]];
    
    int rxPort = [self.oscClientRxPort.stringValue intValue];
    if (rxPort < 1025 || rxPort > 65535) {
        
        return NO;
    }
    
    [usedPorts addObject:[[NSNumber alloc] initWithInt:rxPort]];
    
    NSString* username = self.oscClientUserName.stringValue;
    if ([username isEqualToString:@""]) {
        
        return NO;
    }
    
    NSString* userpwd = self.oscClientUserPwd.stringValue;
    if ([userpwd isEqualToString:@""]) {
        
        return NO;
    }
    
    NSString* groupname = self.oscClientGroupName.stringValue;
    if([groupname isEqualToString:@""]){
        
        return NO;
    }
    
    NSString* grouppwd = self.oscClientGroupPwd.stringValue;
    if ([grouppwd isEqualToString:@""]) {
        
        return NO;
    }
    
    NSString* monitorAddr = self.oscClientMonitorAddr.stringValue;
    if ([monitorAddr isEqualToString:@""]){
        return NO;
    }
    
    int monitorPort = [self.oscClientMonitorPort intValue];
    if (monitorPort < 1025 || monitorPort > 65535) {
        
        return NO;
    }
    
    return YES;
}

@end
