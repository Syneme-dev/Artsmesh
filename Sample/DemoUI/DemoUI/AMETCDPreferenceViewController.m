//
//  AMETCDPreferenceViewController.m
//  DemoUI
//
//  Created by 王 为 on 3/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMETCDPreferenceViewController.h"
#import "AMNetworkUtils/AMNetworkUtils.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import <UIFramework/AMButtonHandler.h>
#import <UIFramework/AMCheckBoxView.h>
#import <AMCommonTools/AMCommonTools.h>
#import <AMStatusNet/AMStatusNet.h>
#import "AMAppDelegate.h"
#import "AMAudio/AMAudio.h"


@interface AMETCDPreferenceViewController ()<AMCheckBoxDelegeate, AMPopUpViewDelegeate>
@property (weak) IBOutlet AMCheckBoxView *Ipv6checkBox;

@end

@implementation AMETCDPreferenceViewController
{
    dispatch_queue_t _preference_queue;
    NSViewController* _audioViewController;
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
    [AMButtonHandler changeTabTextColor:self.jackRouterTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.jackServerTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.audioTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.videoTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.statusnetTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.testStatusNetPost toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.postStatusMessageButton toColor:UI_Color_blue];
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
}


-(void)loadPrefViews
{
    NSArray* tabItems = [self.tabs tabViewItems];
    
    for (NSTabViewItem* item in tabItems) {
        NSView* view = item.view;
        
        if ([view.identifier isEqualTo:@"generalTab"]) {
            ;
        }else if([view.identifier isEqualTo:@"jackServerTab"]){
            [self loadJackPref:view];
        }else if([view.identifier isEqualTo:@"statusNetTab"]){
            ;
        }
    }
}


-(void)loadJackPref:(NSView*)tabView
{
    _audioViewController = [[AMAudio sharedInstance] getJackPrefUI];
    if (_audioViewController) {
        [tabView addSubview:_audioViewController.view];
        NSRect rect = tabView.bounds;
        [_audioViewController.view setFrame:rect];
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
    [self.tabs selectTabViewItemWithIdentifier:@"6"];
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
        AMAppDelegate *appDelegate=AM_APPDELEGATE;
        [appDelegate.mainWindowController initControlBar:sender.checked];
        [defaults setBool:sender.checked forKey:Preference_Key_General_TopControlBar];
        [appDelegate.mainWindowController loadControlBarItemStatus];
    }
    else{
        [defaults setBool:sender.checked forKey:Preference_Key_General_UseIpv6];
        
        if(sender.checked){
            [self loadIpv6];
            [self changeMesherServerToIpv6:YES];
        }else{
            [self loadIpv4];
            [self changeMesherServerToIpv6:NO];
        }
    }
}

@end
