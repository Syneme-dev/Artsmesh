//
//  AMETCDPreferenceViewController.m
//  DemoUI
//
//  Created by 王 为 on 3/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMPreferenceVC.h"
#import "AMNetworkUtils/AMNetworkUtils.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import <UIFramework/AMButtonHandler.h>
#import <UIFramework/AMCheckBoxView.h>
#import <AMCommonTools/AMCommonTools.h>
#import <AMStatusNet/AMStatusNet.h>
#import "AMAppDelegate.h"
#import "AMAudio/AMAudio.h"
#import "AMOSCGroups/AMOSCGroups.h"
#import "AMJacktripSettings.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMMesher/AMMesher.h"
#import "AMJackSettingsVC.h"
#import "UIFramework/NSView_Constrains.h"




@interface AMPreferenceVC ()<AMCheckBoxDelegeate, AMPopUpViewDelegeate>

@property (weak) IBOutlet NSButton *statusNetPostMessage;
@property (weak) IBOutlet AMCheckBoxView *forceLoalServerIpBox;
@property (weak) IBOutlet AMFoundryFontView *forceLocalServerIpField;
@property (weak) IBOutlet AMCheckBoxView *useOSCForChat;

@end

@implementation AMPreferenceVC
{
    dispatch_queue_t _preference_queue;
    NSViewController* _oscGroupVC;
    NSViewController* _jacktripSettingVC;
    NSViewController * _jackSettingsVC;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}


-(void)awakeFromNib{
    [super awakeFromNib];
    [AMButtonHandler changeTabTextColor:self.generalTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.oscGroupTabBtn  toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.jackServerTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.audioTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.videoTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.statusnetTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.testStatusNetPost toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.postStatusMessageButton toColor:UI_Color_blue];
    
    [AMButtonHandler changeTabTextColor:self.statusNetPostMessage toColor:UI_Color_blue];
    _preference_queue = dispatch_queue_create("preference_queue", DISPATCH_QUEUE_SERIAL);
    
    self.Ipv6checkBox.readOnly= NO;
    self.Ipv6checkBox.title = @"USE IPV6";
    self.Ipv6checkBox.delegate = self;
    self.isTopControlBarCheckBox.delegate=self;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL isTopBar = [defaults boolForKey:Preference_Key_General_TopControlBar];

    self.isTopControlBarCheckBox.checked=isTopBar;
    self.isTopControlBarCheckBox.title = @"CONTROL BAR TOP";
    self.isTopControlBarCheckBox.font = [NSFont fontWithName: @"FoundryMonoline-Bold" size: 13];
    
    self.ipPopUpView.delegate = self;
    
    [self loadPrefViews];
    [self onGeneralClick:self.generalTabButton];
    
    self.forceLoalServerIpBox.title = @"USE LOCAL SERVER IP";
    self.forceLoalServerIpBox.checked = NO;
    self.forceLoalServerIpBox.delegate = self;
    
    self.useOSCForChat.title = @"USE OSC FOR CHAT";
    self.useOSCForChat.checked = [[defaults stringForKey:Preference_Key_General_UseOSCForChat] boolValue];
    self.useOSCForChat.delegate = self;
}


-(void)loadPrefViews
{
    NSArray* tabItems = [self.tabs tabViewItems];
    
    for (NSTabViewItem* item in tabItems) {
        NSView* view = item.view;
        
        if ([view.identifier isEqualTo:@"generalTab"]) {
            ;
        }else if([view.identifier isEqualTo:@"jackServerTab"]){
            [self loadJackSettingsVC:view];
        }else if([view.identifier isEqualTo:@"statusNetTab"]){
            ;
        }else if([view.identifier isEqualTo:@"oscGroupTab"]){
            [self loadOSCGroupPrefView:view ];
        }else if([view.identifier isEqualTo:@"jacktripTab"]){
            [self loadJacktripTab:view ];
        }
    }
}


-(void)loadJacktripTab:(NSView *)tabView
{
    _jacktripSettingVC = [[AMJacktripSettings alloc] initWithNibName:@"AMJacktripSettings" bundle:nil];
    if (_jacktripSettingVC) {
        
        [tabView addConstrainsToSubview:_jacktripSettingVC.view
                           leadingSpace:0 trailingSpace:0 topSpace:0 bottomSpace:0];
    }
}

-(void)loadJackSettingsVC:(NSView *)tabView
{
    if (_jackSettingsVC == nil) {
        _jackSettingsVC = [[AMJackSettingsVC alloc] init];
    }
    
    if (_jackSettingsVC) {
        [tabView addConstrainsToSubview:_jackSettingsVC.view
                           leadingSpace:0 trailingSpace:0 topSpace:0 bottomSpace:0];
    }
}

-(void)loadOSCGroupPrefView:(NSView*)tabView
{
    _oscGroupVC = [[AMOSCGroups sharedInstance] getOSCPrefUI];
    if(_oscGroupVC){
        [tabView addConstrainsToSubview:_oscGroupVC.view
                           leadingSpace:0 trailingSpace:0 topSpace:0 bottomSpace:0];
    }
}


- (IBAction)onJackServerTabClick:(id)sender {
    [self pushDownButton:self.jackServerTabButton];
    [self.tabs selectTabViewItemWithIdentifier:@"1"];
}


-(void)registerTabButtons
{
    super.tabs=self.tabs;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.generalTabButton];
    [self.tabButtons addObject:self.postStatusMessageButton];
    self.showingTabsCount=2;
}


-(void)itemSelected:(AMPopUpView*)sender{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* myPrivateIP = [self.ipPopUpView stringValue];
    [defaults setObject:myPrivateIP forKey:Preference_Key_User_PrivateIp];
}


- (IBAction)statusNetTest:(id)sender {
    BOOL res = [[AMStatusNet shareInstance] postMessageToStatusNet:@"This is a test message send from Artsmesh through API"];
    if (res)
    {
        self.statusNetPostTestResult.stringValue = @"Post Succeeded!";
    }
    else
    {
        self.statusNetPostTestResult.stringValue = @"Post Failed!";
    }
}


- (IBAction)onGeneralClick:(id)sender {
    [self pushDownButton:self.generalTabButton];
    [self.tabs selectTabViewItemWithIdentifier:@"0"];
}


- (IBAction)onStatusNetClick:(id)sender {
    [self pushDownButton:self.statusnetTabButton];
    [self.tabs selectTabViewItemWithIdentifier:@"5"];
}


- (IBAction)onOSCGroupClick:(id)sender {
    [self pushDownButton:self.oscGroupTabBtn];
    [self.tabs selectTabViewItemWithIdentifier:@"3"];
}


- (IBAction)onJackTripClick:(id)sender {
    [self pushDownButton:self.audioTabButton];
    [self.tabs selectTabViewItemWithIdentifier:@"2"];
}


-(void)loadIpv4
{
    dispatch_async(_preference_queue, ^{
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            NSString* oldIp = [defaults stringForKey:Preference_Key_User_PrivateIp];
            BOOL ipSelected = NO;
            int popupIndex = 0;
            
            [self.ipPopUpView removeAllItems];
            
            for (NSString* ipStr in ipv4s) {
                [self.ipPopUpView addItemWithTitle:ipStr];
                
                if ([ipStr isEqualToString:oldIp])
                {
                    [self.ipPopUpView selectItemAtIndex:popupIndex];
                    ipSelected = YES;
                }
                
                 popupIndex++;
            }
            
            if (!ipSelected && [self.ipPopUpView itemCount] > 0)
            {
                [self.ipPopUpView selectItemAtIndex:0];
                NSString* myPrivateIP = [self.ipPopUpView stringValue];
                [defaults setObject:myPrivateIP forKey:Preference_Key_User_PrivateIp];
            }
        });
    
    });
}


-(void) loadIpv6
{
    dispatch_async(_preference_queue, ^{
        NSArray* addresses = [NSHost currentHost].addresses;
        NSMutableArray* ipv6s = [[NSMutableArray alloc]init];
        for (int i = 0; i < [addresses count]; i++)
        {
            NSString* ipStr = [addresses objectAtIndex:i];
            if ([AMCommonTools isValidIpv6:ipStr])
            {
                NSArray* ipStrComponents = [ipStr componentsSeparatedByString:@"%"];
                //ipStr = [NSString stringWithFormat:@"[%@]", [ipStrComponents objectAtIndex:0]];
                ipStr = [NSString stringWithFormat:@"%@", [ipStrComponents objectAtIndex:0]];
                
                [ipv6s addObject:ipStr];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            NSString* oldIp = [defaults stringForKey:Preference_Key_User_PrivateIp];
            BOOL ipSelected = NO;
            int popupIndex = 0;
            
            [self.ipPopUpView removeAllItems];
            
            for (NSString* ipStr in ipv6s) {
                [self.ipPopUpView addItemWithTitle:ipStr];

                if ([ipStr isEqualToString:oldIp])
                {
                    [self.ipPopUpView selectItemAtIndex:popupIndex];
                    ipSelected = YES;
                }
                
                popupIndex++;
            }
            
            if (!ipSelected && [self.ipPopUpView itemCount] > 0)
            {
                [self.ipPopUpView selectItemAtIndex:0];
                NSString* myPrivateIP = [self.ipPopUpView stringValue ];
                [defaults setObject:myPrivateIP forKey:Preference_Key_User_PrivateIp];
            }
        });
        
    });
}


-(void)loadMachineName
{
    dispatch_async(_preference_queue, ^{
        NSHost* host = [NSHost currentHost];
        NSString* machineName = host.name;
        
        self.myMachineNameField.stringValue = machineName;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:machineName forKey:Preference_Key_General_MachineName];
        });
    });
}


-(void)loadSystemInfo
{
    [self loadMachineName];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL useIpv6 = [defaults boolForKey:Preference_Key_General_UseIpv6];
    
    if (useIpv6)
    {
        self.Ipv6checkBox.checked = YES;
        [self loadIpv6];
    }
    else
    {
        self.Ipv6checkBox.checked = NO;
        [self loadIpv4];
    }
}


-(void)changeMesherServerToIpv6:(BOOL)isIpv6{
    NSUserDefaults* defaults = [AMPreferenceManager standardUserDefaults];
    NSString* gAddr = [defaults stringForKey:Preference_Key_General_GlobalServerAddr];
    if(![AMCommonTools isValidIpv4:gAddr] && ![AMCommonTools isValidIpv6:gAddr]){
        if (isIpv6) {
            gAddr = [NSString stringWithFormat:@"ipv6.%@", gAddr];
        }else{
            if ([gAddr hasPrefix:@"ipv6"]) {
                gAddr = [gAddr substringFromIndex:5];
            }
        }
        
        [defaults setObject:gAddr forKey:Preference_Key_General_GlobalServerAddr];
    }
}


-(void)onChecked:(AMCheckBoxView *)sender
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if([sender.identifier isEqualToString:@"isTopControlBar"]){
        [defaults setBool:sender.checked forKey:Preference_Key_General_TopControlBar];
        AMAppDelegate *appDelegate=AM_APPDELEGATE;
        [appDelegate.mainWindowController loadControlBar];
    }else if([sender.identifier isEqualToString:@"useIpv6"]){
        [defaults setBool:sender.checked forKey:Preference_Key_General_UseIpv6];
        
        if(sender.checked){
            [self loadIpv6];
            [self changeMesherServerToIpv6:YES];
        }else{
            [self loadIpv4];
            [self changeMesherServerToIpv6:NO];
        }
    }else if([sender.identifier isEqualToString:@"useLocalServerIP"]){
        
        if (sender.checked == YES) {
            if (![self.forceLocalServerIpField.stringValue isEqualTo:@""]) {
                AMSystemConfig * config = [AMCoreData shareInstance].systemConfig;
                config.localServerIps = @[self.forceLocalServerIpField.stringValue];
                
                [[AMMesher sharedAMMesher] stopMesher];
                [[AMMesher sharedAMMesher] startMesher];
            }
            
        }else{
            AMSystemConfig * config = [AMCoreData shareInstance].systemConfig;
            config.localServerIps = nil;
            
            [[AMMesher sharedAMMesher] stopMesher];
            [[AMMesher sharedAMMesher] startMesher];
            
        }
    }else if([sender.identifier isEqualToString:@"useOSCForChat"]){
        
        if (sender.checked) {
            [defaults setObject:@"YES" forKey:Preference_Key_General_UseOSCForChat];
        }else{
            [defaults setObject:@"NO" forKey:Preference_Key_General_UseOSCForChat];
        }
    }
}

@end
