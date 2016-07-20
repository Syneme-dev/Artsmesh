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
#import "AMTheme.h"

@interface AMGeneralSettingsVC ()<AMPopUpViewDelegeate, AMCheckBoxDelegeate>

@property (weak) IBOutlet NSTextField *machineNameField;
@property (weak) IBOutlet AMPopUpView *privateIpBox;
@property (weak) IBOutlet AMPopUpView *privateIpv6Box;
@property (weak) IBOutlet AMPopUpView *themeDrop;

@property (weak) IBOutlet NSTextField *localServerPortField;
@property (weak) IBOutlet AMCheckBoxView*  meshUseIpv6Check;
@property (weak) IBOutlet AMCheckBoxView*  heartbeatUseIpv6Check;
@property (weak) IBOutlet AMCheckBoxView *assignedLocalServerCheck;
@property (weak) IBOutlet NSTextField *assignedLocalServerField;
@property (weak) IBOutlet AMPopUpView *localServerConfigDrop;
@property (weak) IBOutlet NSTextField *globalServerAddrFieldIpv4;
@property (weak) IBOutlet NSTextField *globalServerAddrFieldIpv6;
@property (weak) IBOutlet NSTextField *globalServerPortField;
@property (weak) IBOutlet NSTextField *chatPortField;
@property (weak) IBOutlet AMCheckBoxView *useOSCForChatCheck;
@property (weak) IBOutlet AMCheckBoxView *topBarCheck;
@property (strong) NSMutableArray *LSConfigOptions;
@property (strong) NSArray *themes;

@end

@implementation AMGeneralSettingsVC
{
    dispatch_queue_t _loading_queue;
}

-(NSArray *)myIpv4Addr{
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
-(NSArray *)myIpv6Addr{
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
-(NSArray *)myGlobalIpv6Addr{
    NSArray* addresses = [NSHost currentHost].addresses;
    NSMutableArray* ipv6s = [[NSMutableArray alloc]init];
    for (int i = 0; i < [addresses count]; i++)
    {
        NSString* ipStr = [addresses objectAtIndex:i];
        if ([AMCommonTools isValidGlobalIpv6:ipStr])
        {
            NSArray* ipStrComponents = [ipStr componentsSeparatedByString:@"%"];
            ipStr = [NSString stringWithFormat:@"%@", [ipStrComponents objectAtIndex:0]];
            [ipv6s addObject:ipStr];
        }
    }
    
    return ipv6s;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLSConfigIps) name:AM_LIVE_GROUP_CHANDED object:nil];
    
    _LSConfigOptions = [[NSMutableArray alloc] initWithObjects:@"DISCOVER",@"SELF", nil];
    _themes = [[NSArray alloc] initWithObjects:@"dark",@"light", nil];
    
    for (NSString *themeName in _themes) {
        [self.themeDrop addItemWithTitle:themeName];
    }
    [self.themeDrop selectItemWithTitle:[[NSUserDefaults standardUserDefaults] stringForKey: Preference_Key_Active_Theme]];
    
//    self.privateIpBox.delegate = self;
//    self.privateIpv6Box.delegate = self;
//    self.meshUseIpv6Check.delegate      = self;
//    self.heartbeatUseIpv6Check.delegate = self;
//    self.assignedLocalServerCheck.delegate = self;
//    self.localServerConfigDrop.delegate = self;
//    self.useOSCForChatCheck.delegate = self;
//    self.topBarCheck.delegate = self;
    
    self.heartbeatUseIpv6Check.title    = @"HEARTBEAT USE IPV6";
    self.assignedLocalServerCheck.title = @"USE LOCAL SERVER IP";
    self.useOSCForChatCheck.title = @"USE OSC FOR CHAT";
    self.meshUseIpv6Check.title         = @"MESH USE IPV6";
    self.topBarCheck.title = @"CONTROL BAR TOP";
    
    [self reloadSettings];
}

-(void)loadMachineName{
    dispatch_async([self loadingQueue], ^{
        
        NSHost* host = [NSHost currentHost];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.machineNameField.stringValue = host.name;
            [[NSUserDefaults standardUserDefaults] setObject:host.name forKey:Preference_Key_General_MachineName];
        });
    });
}


-(dispatch_queue_t)loadingQueue{
    if (_loading_queue == nil) {
        _loading_queue = dispatch_queue_create("_loading_queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return _loading_queue;
}

-(void)loadUseIpv6{
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

-(void)drawLocalServerOptions:(NSMutableArray *)options {
    dispatch_async([self loadingQueue], ^{
        [self.localServerConfigDrop removeAllItems];
        [self.localServerConfigDrop addItemsWithTitles:options];
        [self selectLastLSConfig];
        [self storeSelectedLSConfig];
        [self.localServerConfigDrop setNeedsDisplay];
    });
}

-(void)loadLSConfigIps {
    [_LSConfigOptions removeAllObjects];
    [_LSConfigOptions addObject:@"DISCOVER"];
    [_LSConfigOptions addObject:@"SELF"];
    
    AMLiveUser *mySelf = [AMCoreData shareInstance].mySelf;
    AMLiveGroup *myLiveGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    
    for (AMLiveUser *curUser in myLiveGroup.users) {
        if (!self.meshUseIpv6Check.checked && ![curUser.privateIp isEqualToString:mySelf.privateIp]) {
            [_LSConfigOptions addObject:curUser.privateIp];
        } else if (![curUser.ipv6Address isEqualToString:mySelf.ipv6Address]) {
            [_LSConfigOptions addObject:curUser.ipv6Address];
        }
    }
    
    [self drawLocalServerOptions:_LSConfigOptions];
}

-(void)loadPrivateIp{
    dispatch_async([self loadingQueue], ^{
        
        NSArray *addresses;
        if (!self.meshUseIpv6Check.checked) {
            addresses = [self myIpv4Addr];
        }else{
           
            addresses = [self myIpv4Addr];
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
-(void) loadIpv6 {
    dispatch_async([self loadingQueue], ^{
        
//        NSArray *addresses = [self myIpv6Addr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.privateIpv6Box removeAllItems];
            [self.privateIpv6Box addItemsWithTitles:[self myIpv6Addr]];
            [self selectLastIpv6];
            [self storeUsedIpv6];
            [self.privateIpv6Box setNeedsDisplay];
        });
    });
}

-(void)selectLastPrivateIp{
    NSString* lastUsedIp = [[NSUserDefaults standardUserDefaults]
                            stringForKey:Preference_Key_User_PrivateIp];
    
    [self.privateIpBox selectItemWithTitle:lastUsedIp];
    if ([self.privateIpBox.stringValue isEqualTo:@""] && self.privateIpBox.itemCount > 0) {
        [self.privateIpBox selectItemAtIndex:0];
    }
}

-(void)selectLastIpv6 {
    NSString* lastUsedIpv6 = [[NSUserDefaults standardUserDefaults]
                              stringForKey:Preference_Key_User_Ipv6Address];
    
    [self.privateIpv6Box selectItemWithTitle:lastUsedIpv6];
    if ([self.privateIpv6Box.stringValue isEqualTo:@""] && self.privateIpv6Box.itemCount > 0) {
        [self.privateIpv6Box selectItemAtIndex:0];
    }
}

-(void)selectLastLSConfig {
    NSString *lastLSConfig = [[NSUserDefaults standardUserDefaults] stringForKey:Preference_Key_Cluster_LSConfig];
    
    NSLog(@"last used ls config is: %@", lastLSConfig);
    if (![lastLSConfig isEqualToString:@"DISCOVER"] && ![lastLSConfig isEqualToString:@"SELF"] && ([lastLSConfig length] > 0)) {
        NSLog(@"config is set to manual IP, need to add it to options");
        //LS Config is set to manual IP connect, need to add it to options and set it as selected option
        NSMutableArray *lsConfigOptions = [[NSMutableArray alloc] initWithObjects:@"DISCOVER",@"SELF", nil];
        
        [lsConfigOptions addObject:lastLSConfig];
        
        [self.localServerConfigDrop removeAllItems];
        [self.localServerConfigDrop addItemsWithTitles:lsConfigOptions];
    }
    
    [self.localServerConfigDrop selectItemWithTitle:lastLSConfig];
    if ([self.localServerConfigDrop.stringValue isEqualTo:@""] && self.localServerConfigDrop.itemCount > 0) {
        [self.localServerConfigDrop selectItemAtIndex:0];
    }
    
}

-(void)storeUsedPrivateIp{
    [[NSUserDefaults standardUserDefaults] setObject:self.privateIpBox.stringValue forKey:Preference_Key_User_PrivateIp];
}
-(void)storeUsedIpv6 {
    [[NSUserDefaults standardUserDefaults] setObject:self.privateIpv6Box.stringValue forKey:Preference_Key_User_Ipv6Address];
}
-(void)storeSelectedLSConfig {
    [[NSUserDefaults standardUserDefaults] setObject:self.localServerConfigDrop.stringValue forKey:Preference_Key_Cluster_LSConfig];
}

-(void)loadGlobalServerAddr{
    self.globalServerAddrFieldIpv4.stringValue =
    [[NSUserDefaults standardUserDefaults]
     stringForKey:Preference_Key_General_GlobalServerAddrIpv4];
    
    self.globalServerAddrFieldIpv6.stringValue =
    [[NSUserDefaults standardUserDefaults]
     stringForKey:Preference_Key_General_GlobalServerAddrIpv6];
}

#pragma mark AMPopUpViewDelegeate
-(void)itemSelected:(AMPopUpView*)sender{
    if (sender == self.privateIpBox) {
        [[NSUserDefaults standardUserDefaults] setObject:self.privateIpBox.stringValue forKey:Preference_Key_User_PrivateIp];
    } else if (sender == self.privateIpv6Box) {
        [[NSUserDefaults standardUserDefaults] setObject:self.privateIpv6Box.stringValue forKey:Preference_Key_User_Ipv6Address];
    } else if (sender == self.localServerConfigDrop) {
        [[NSUserDefaults standardUserDefaults] setObject:self.localServerConfigDrop.stringValue forKey:Preference_Key_Cluster_LSConfig];
    } else if (sender == self.themeDrop) {
        [[NSUserDefaults standardUserDefaults] setObject:self.themeDrop.stringValue forKey:Preference_Key_Active_Theme];
        [[AMTheme sharedInstance] setTheme:self.themeDrop.stringValue];
    }
}

#pragma mark AMCheckBoxDelegeate
-(void)onChecked:(AMCheckBoxView*)sender{
    if (sender == self.meshUseIpv6Check) {
        [[NSUserDefaults standardUserDefaults] setBool:self.meshUseIpv6Check.checked
                                                forKey:Preference_Key_General_MeshUseIpv6];
        [AMCoreData shareInstance].systemConfig.meshUseIpv6 = self.meshUseIpv6Check.checked;
        [self loadPrivateIp];
        [self loadIpv6];
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

- (IBAction)saveConfig:(NSButton *)sender{
    [self itemSelected:self.privateIpv6Box];
    [self itemSelected:self.privateIpBox];
    [self itemSelected:self.localServerConfigDrop];
    [self itemSelected:self.themeDrop];
    [self onChecked:self.meshUseIpv6Check];
    [self onChecked:self.heartbeatUseIpv6Check];
    [self onChecked:self.useOSCForChatCheck];
    [self onChecked:self.topBarCheck];
    
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.localServerPortField.stringValue
     forKey:Preference_Key_General_LocalServerPort];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.globalServerAddrFieldIpv4.stringValue
     forKey:Preference_Key_General_GlobalServerAddrIpv4];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.globalServerAddrFieldIpv6.stringValue
     forKey:Preference_Key_General_GlobalServerAddrIpv6];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.globalServerPortField.stringValue
     forKey:Preference_Key_General_GlobalServerPort];
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.chatPortField.stringValue
     forKey:Preference_Key_General_ChatPort];
    
    
}


-(void) reloadSettings{
    [self loadMachineName];
    [self loadUseIpv6];
    [self loadPrivateIp];
    [self loadIpv6];
    [self drawLocalServerOptions:_LSConfigOptions];
    [self loadGlobalServerAddr];
    self.localServerPortField.stringValue = [[NSUserDefaults standardUserDefaults]
                                             stringForKey:Preference_Key_General_LocalServerPort];
    
    self.globalServerPortField.stringValue = [[NSUserDefaults standardUserDefaults]
                                              stringForKey:Preference_Key_General_GlobalServerPort];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:Preference_Key_General_TopControlBar]) {
        self.topBarCheck.checked = YES;
    }else{
        self.topBarCheck.checked = NO;
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:Preference_Key_General_UseOSCForChat]) {
        self.useOSCForChatCheck.checked = YES;
    }else{
        self.useOSCForChatCheck.checked = NO;
    }
    self.chatPortField.stringValue = [[NSUserDefaults standardUserDefaults]
                                      stringForKey:Preference_Key_General_ChatPort];
    
}

- (IBAction)restoreConfig:(NSButton *)sender{
    [self reloadSettings];
    
}



@end
