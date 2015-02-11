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
#import "AMJacktripSettingsVC.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMMesher/AMMesher.h"

#import "AMJackSettingsVC.h"
#import "AMStatusNetSettingsVC.h"
#import "AMOSCGroupSettingsVC.h"
#import "AMJacktripSettingsVC.h"
#import "AMGeneralSettingsVC.h"
#import "UIFramework/NSView_Constrains.h"


@interface AMPreferenceVC ()<AMCheckBoxDelegeate, AMPopUpViewDelegeate>
@end

@implementation AMPreferenceVC
{
    dispatch_queue_t _preference_queue;
    
    NSViewController    *_generalSettingsVC;
    NSViewController    *_oscGroupSettingsVC;
    NSViewController    *_jacktripSettingVC;
    NSViewController    *_jackSettingsVC;
    NSViewController    *_statusNetSettingsVC;
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
    [AMButtonHandler changeTabTextColor:self.generalTabBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.oscGroupTabBtn  toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.jackTabBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.jacktripTabBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.videoTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.statusnetTabButton toColor:UI_Color_blue];
    
    [self loadPrefViews];
    [self onGeneralClick:self.generalTabBtn];
}


-(void)loadPrefViews
{
    NSArray* tabItems = [self.tabs tabViewItems];
    
    for (NSTabViewItem* item in tabItems) {
        NSView* view = item.view;
        
        if ([view.identifier isEqualTo:@"general"]) {
            [self loadGeneralPage:view];;
        }else if([view.identifier isEqualTo:@"jack"]){
            [self loadJackPage:view];
        }else if([view.identifier isEqualTo:@"jacktrip"]){
            [self loadJacktripPage:view];
        }else if([view.identifier isEqualTo:@"oscGroups"]){
            [self loadOSCGroupPage:view ];
        }else if([view.identifier isEqualTo:@"statusNet"]){
            [self loadStatusNetPage:view ];
        }
    }
}


-(void)loadGeneralPage:(NSView*)tabView
{
    if (_generalSettingsVC == nil) {
        _generalSettingsVC = [[AMGeneralSettingsVC alloc] init];
    }
    
    if(_generalSettingsVC){
        [tabView addConstrainsToSubview:_generalSettingsVC.view
                           leadingSpace:0 trailingSpace:0 topSpace:0 bottomSpace:0];
    }
}


-(void)loadJackPage:(NSView *)tabView
{
    if (_jackSettingsVC == nil) {
        _jackSettingsVC = [[AMJackSettingsVC alloc] init];
    }
    
    if (_jackSettingsVC) {
        [tabView addConstrainsToSubview:_jackSettingsVC.view
                           leadingSpace:0 trailingSpace:0 topSpace:0 bottomSpace:0];
    }
}


-(void)loadJacktripPage:(NSView *)tabView
{
    _jacktripSettingVC = [[AMJacktripSettingsVC alloc] init];
    if (_jacktripSettingVC) {
        
        [tabView addConstrainsToSubview:_jacktripSettingVC.view
                           leadingSpace:0 trailingSpace:0 topSpace:0 bottomSpace:0];
    }
}


-(void)loadOSCGroupPage:(NSView*)tabView
{
    if (_oscGroupSettingsVC == nil) {
        _oscGroupSettingsVC = [[AMOSCGroupSettingsVC alloc] init];
    }
    
    if(_oscGroupSettingsVC){
        [tabView addConstrainsToSubview:_oscGroupSettingsVC.view
                           leadingSpace:0 trailingSpace:0 topSpace:0 bottomSpace:0];
    }
}


-(void)loadStatusNetPage:(NSView*)tabView
{
    if (_statusNetSettingsVC == nil) {
        _statusNetSettingsVC = [[AMStatusNetSettingsVC alloc] init];
    }
    
    if(_statusNetSettingsVC){
        [tabView addConstrainsToSubview:_statusNetSettingsVC.view
                           leadingSpace:0 trailingSpace:0 topSpace:0 bottomSpace:0];
    }
}




-(void)registerTabButtons
{
    super.tabs=self.tabs;
//    self.tabButtons =[[NSMutableArray alloc]init];
//    [self.tabButtons addObject:self.generalTabButton];
//    [self.tabButtons addObject:self.postStatusMessageButton];
//    self.showingTabsCount=2;
    
    super.tabs=self.tabs;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.generalTabBtn];
    [self.tabButtons addObject:self.jackTabBtn];
    [self.tabButtons addObject:self.jacktripTabBtn];
    [self.tabButtons addObject:self.oscGroupTabBtn];
    [self.tabButtons addObject:self.statusnetTabButton];
    self.showingTabsCount=5;
}

- (IBAction)onGeneralClick:(id)sender {
    [self pushDownButton:self.generalTabBtn];
    [self.tabs selectTabViewItemWithIdentifier:@"0"];
}

- (IBAction)onJackClick:(id)sender {
    [self pushDownButton:self.jackTabBtn];
    [self.tabs selectTabViewItemWithIdentifier:@"1"];
}


- (IBAction)onJackTripClick:(id)sender {
    [self pushDownButton:self.jacktripTabBtn];
    [self.tabs selectTabViewItemWithIdentifier:@"2"];
}


- (IBAction)onOSCGroupClick:(id)sender {
    [self pushDownButton:self.oscGroupTabBtn];
    [self.tabs selectTabViewItemWithIdentifier:@"3"];
}


- (IBAction)onStatusNetClick:(id)sender {
    [self pushDownButton:self.statusnetTabButton];
    [self.tabs selectTabViewItemWithIdentifier:@"5"];
}







@end
