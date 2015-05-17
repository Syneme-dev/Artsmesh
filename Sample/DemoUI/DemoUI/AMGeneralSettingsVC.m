//
//  AMGeneralSettingsVC.m
//  Artsmesh
//
//  Created by 王为 on 11/2/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMGeneralSettingsVC.h"
#import "UIFramework/AMPopUpView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMCommonTools/AMCommonTools.h"
#import "AMCoreData/AMCoreData.h"
#import "AMMesher/AMMesher.h"
#import "AMAppDelegate.h"

@interface AMGeneralSettingsVC ()<AMPopUpViewDelegeate, AMCheckBoxDelegeate>

@property (weak) IBOutlet NSTextField *machineNameField;
@property (weak) IBOutlet AMPopUpView *privateIpBox;
@property (weak) IBOutlet NSTextField *localServerPortField;
@property (weak) IBOutlet AMCheckBoxView*  meshUseIpv6Check;
@property (weak) IBOutlet AMCheckBoxView*  heartbeatUseIpv6Check;

@property (weak) IBOutlet AMCheckBoxView *assignedLocalServerCheck;
@property (weak) IBOutlet NSTextField *assignedLocalServerField;
@property (weak) IBOutlet NSTextField *globalServerAddrFieldIpv4;
@property (weak) IBOutlet NSTextField *globalServerAddrFieldIpv6;
@property (weak) IBOutlet NSTextField *globalServerPortField;
@property (weak) IBOutlet NSTextField *chatPortField;
@property (weak) IBOutlet AMCheckBoxView *useOSCForChatCheck;
@property (weak) IBOutlet AMCheckBoxView *topBarCheck;


@end

@implementation AMGeneralSettingsVC
{
    dispatch_queue_t _loading_queue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.privateIpBox.delegate = self;
    
    self.meshUseIpv6Check.delegate      = self;
    self.meshUseIpv6Check.title         = @"MESH USE IPV6";
    self.heartbeatUseIpv6Check.delegate = self;
    self.heartbeatUseIpv6Check.title    = @"HEARTBEAT USE IPV6";
    
    self.assignedLocalServerCheck.delegate = self;
    self.assignedLocalServerCheck.title = @"USE LOCAL SERVER IP";
    
    self.useOSCForChatCheck.delegate = self;
    self.useOSCForChatCheck.title = @"USE OSC FOR CHAT";
    
    self.topBarCheck.delegate = self;
    self.topBarCheck.title = @"CONTROL BAR TOP";
    
    [self loadMachineName];
    [self loadUseIpv6];
    [self loadPrivateIp];
    [self loadLocalServerPort];
    [self loadGlobalServerAddr];
    [self loadGlobalServerPort];
    [self loadChatPort];
    [self loadUseOscForChat];
    [self loadTopBarCheck];
}


-(void)loadMachineName
{
    dispatch_async([self loadingQueue], ^{
        
        NSHost* host = [NSHost currentHost];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateMachineName:host.name];
        });
    });
}


-(void)updateMachineName:(NSString *)name
{
    self.machineNameField.stringValue = name;
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:Preference_Key_General_MachineName];
}


-(dispatch_queue_t)loadingQueue
{
    if (_loading_queue == nil) {
        _loading_queue = dispatch_queue_create("_loading_queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return _loading_queue;
}


-(void)loadUseIpv6
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:
         Preference_Key_General_MeshUseIpv6]) {
        self.meshUseIpv6Check.checked = YES;
        
    }else{
        self.meshUseIpv6Check.checked = NO;
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:
        Preference_Key_General_HeartbeatUseIpv6]){
        self.heartbeatUseIpv6Check.checked = YES;
    }else{
        self.heartbeatUseIpv6Check.checked = NO;
    }
}


-(void)loadPrivateIp
{
    dispatch_async([self loadingQueue], ^{
        
        NSArray *addresses;
        if (!self.meshUseIpv6Check.checked) {
            addresses = [self myIpv4Addr];
        }else{
            addresses = [self myIpv6Addr];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.privateIpBox removeAllItems];
            [self.privateIpBox addItemsWithTitles:addresses];
            [self selectLastPrivateIp];
            [self storeUsedPrivateIp];
            [self.privateIpBox setNeedsDisplay];
        });
    });
}


-(NSArray *)myIpv4Addr
{
    NSArray* addresses = [NSHost currentHost].addresses;
    NSMutableArray* ipv4s = [[NSMutableArray alloc]init];
    for (int i = 0; i < [addresses count]; i++)
    {
        NSString* ipStr = [addresses objectAtIndex:i];
        if ([AMCommonTools isValidIpv4:ipStr])
        {
            [ipv4s addObject:ipStr];
        }
    }
    
    return ipv4s;
}


-(NSArray *)myIpv6Addr
{
    NSArray* addresses = [NSHost currentHost].addresses;
    NSMutableArray* ipv6s = [[NSMutableArray alloc]init];
    for (int i = 0; i < [addresses count]; i++)
    {
        NSString* ipStr = [addresses objectAtIndex:i];
        if ([AMCommonTools isValidIpv6:ipStr])
        {
            NSArray* ipStrComponents = [ipStr componentsSeparatedByString:@"%"];
            ipStr = [NSString stringWithFormat:@"%@", [ipStrComponents objectAtIndex:0]];
            [ipv6s addObject:ipStr];
        }
    }
    
    return ipv6s;
}


-(void)selectLastPrivateIp
{
    NSString* lastUsedIp = [[NSUserDefaults standardUserDefaults]
                            stringForKey:Preference_Key_User_PrivateIp];
    
    [self.privateIpBox selectItemWithTitle:lastUsedIp];
    if ([self.privateIpBox.stringValue isEqualTo:@""] && self.privateIpBox.itemCount > 0) {
        [self.privateIpBox selectItemAtIndex:0];
    }
}


-(void)storeUsedPrivateIp
{
    [[NSUserDefaults standardUserDefaults] setObject:self.privateIpBox.stringValue forKey:Preference_Key_User_PrivateIp];
}


-(void)loadLocalServerPort
{
    self.localServerPortField.stringValue = [[NSUserDefaults standardUserDefaults]
                                             stringForKey:Preference_Key_General_LocalServerPort];
}

-(void)loadGlobalServerAddr
{
    self.globalServerAddrFieldIpv4.stringValue =
                    [[NSUserDefaults standardUserDefaults]
                        stringForKey:Preference_Key_General_GlobalServerAddrIpv4];
 
    self.globalServerAddrFieldIpv6.stringValue =
                    [[NSUserDefaults standardUserDefaults]
                        stringForKey:Preference_Key_General_GlobalServerAddrIpv6];
}

-(void)loadGlobalServerPort
{
    self.globalServerPortField.stringValue = [[NSUserDefaults standardUserDefaults]
                                              stringForKey:Preference_Key_General_GlobalServerPort];
}


-(void)loadChatPort
{
    self.chatPortField.stringValue = [[NSUserDefaults standardUserDefaults]
                                      stringForKey:Preference_Key_General_ChatPort];
}

-(void)loadUseOscForChat
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:Preference_Key_General_UseOSCForChat]) {
        self.useOSCForChatCheck.checked = YES;
    }else{
        self.useOSCForChatCheck.checked = NO;
    }
}

-(void)loadTopBarCheck
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:Preference_Key_General_TopControlBar]) {
        self.topBarCheck.checked = YES;
    }else{
        self.topBarCheck.checked = NO;
    }
}


#pragma mark AMPopUpViewDelegeate
-(void)itemSelected:(AMPopUpView*)sender
{
    if (sender == self.privateIpBox) {
        [[NSUserDefaults standardUserDefaults] setObject:self.privateIpBox.stringValue forKey:Preference_Key_User_PrivateIp];
    }
}

#pragma mark AMCheckBoxDelegeate
-(void)onChecked:(AMCheckBoxView*)sender
{
    if (sender == self.meshUseIpv6Check) {
        [[NSUserDefaults standardUserDefaults] setBool:self.meshUseIpv6Check.checked
                                                forKey:Preference_Key_General_MeshUseIpv6];
        [AMCoreData shareInstance].systemConfig.meshUseIpv6 = self.meshUseIpv6Check.checked;
        [AMCoreData shareInstance].mySelf.isIPV6 = self.meshUseIpv6Check.checked;
        [self loadPrivateIp];
        [self loadGlobalServerAddr];
        
        return;
    }
    if (sender == self.heartbeatUseIpv6Check) {
        [[NSUserDefaults standardUserDefaults] setBool:self.heartbeatUseIpv6Check.checked
                                                forKey:Preference_Key_General_HeartbeatUseIpv6];
        
        [AMCoreData shareInstance].systemConfig.heartbeatUseIpv6
                                = self.heartbeatUseIpv6Check.checked;
        return;
    }
    
    if (sender == self.assignedLocalServerCheck) {
        
        if ([self.assignedLocalServerField.stringValue isEqualTo:@""]) {
            return;
        }
        
        if (self.assignedLocalServerCheck.checked) {
            [AMCoreData shareInstance].systemConfig.localServerIps = @[self.assignedLocalServerField.stringValue];
        }else{
            [AMCoreData shareInstance].systemConfig.localServerIps = nil;
        }
        
        [[AMMesher sharedAMMesher] stopMesher];
        [[AMMesher sharedAMMesher] startMesher];
        
        return;
    }
    
    if (sender == self.useOSCForChatCheck) {
    
        if (self.useOSCForChatCheck.checked) {
            [[NSUserDefaults standardUserDefaults]
             setObject:@"YES" forKey:Preference_Key_General_UseOSCForChat];
        }else{
            [[NSUserDefaults standardUserDefaults]
             setObject:@"NO" forKey:Preference_Key_General_UseOSCForChat];
        }
        
        return;
    }
    
    if (sender == self.topBarCheck) {
        [[NSUserDefaults standardUserDefaults] setBool:self.topBarCheck.checked forKey:Preference_Key_General_TopControlBar];
        
        AMAppDelegate *appDelegate=AM_APPDELEGATE;
        [appDelegate.mainWindowController loadControlBar];
        
        return;
    }
}



@end
