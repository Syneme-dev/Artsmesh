//
//  AMETCDPreferenceViewController.m
//  DemoUI
//
//  Created by 王 为 on 3/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMPreferenceVC.h"
#import "UIFramework/AMButtonHandler.h"
#import "AMJackSettingsVC.h"
#import "AMAccountSettingsVC.h"
#import "AMOSCGroupSettingsVC.h"
#import "AMJacktripSettingsVC.h"
#import "AMGeneralSettingsVC.h"
#import "AMVideoSettingsVC.h"
#import "UIFramework/NSView_Constrains.h"


@interface AMPreferenceVC ()
@end

@implementation AMPreferenceVC
{
    dispatch_queue_t _preference_queue;
    
    NSViewController    *_generalSettingsVC;
    NSViewController    *_oscGroupSettingsVC;
    NSViewController    *_jacktripSettingVC;
    NSViewController    *_videoSettingsVC;
    NSViewController    *_jackSettingsVC;
    NSViewController    *_accountSettingsVC;
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
    
    self.curTheme = [AMTheme sharedInstance];
    self.textColor = self.curTheme.colorTextPanelTab;
    self.textColorSelected = self.curTheme.colorTextPanelTabSelected;
    
    [AMButtonHandler changeTabTextColor:self.generalTabBtn toColor:self.textColor];
    [AMButtonHandler changeTabTextColor:self.oscGroupTabBtn  toColor:self.textColor];
    [AMButtonHandler changeTabTextColor:self.jackTabBtn toColor:self.textColor];
    [AMButtonHandler changeTabTextColor:self.jacktripTabBtn toColor:self.textColor];
    [AMButtonHandler changeTabTextColor:self.accountTabBtn toColor:self.textColor];
    [AMButtonHandler changeTabTextColor:self.videoTabBtn toColor:self.textColor];
    
    [self loadPrefViews];
    [self onGeneralClick:self.generalTabBtn];
}


-(void)loadPrefViews
{
    NSArray* tabItems = [self.tabs tabViewItems];
    
    for (NSTabViewItem* item in tabItems) {
        NSView* view = item.view;
        
        if ([view.identifier isEqualTo:@"general"]) {
            [self loadGeneralPage:view];
        }else if([view.identifier isEqualTo:@"jack"]){
            [self loadJackPage:view];
        }else if([view.identifier isEqualTo:@"jacktrip"]){
            [self loadJacktripPage:view];
        }else if([view.identifier isEqualTo:@"oscGroups"]){
            [self loadOSCGroupPage:view ];
        }else if([view.identifier isEqualTo:@"statusNet"]){
            [self loadAccountPage:view ];
        }else if([view.identifier isEqualTo:@"video"]) {
            [self loadVideoPage:view];
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

-(void)loadVideoPage:(NSView *)tabView
{
    _videoSettingsVC = [[AMVideoSettingsVC alloc] init];
    if (_videoSettingsVC) {
        [tabView addConstrainsToSubview:_videoSettingsVC.view leadingSpace:0 trailingSpace:0 topSpace:0 bottomSpace:0];
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


-(void)loadAccountPage:(NSView*)tabView
{
    if (_accountSettingsVC == nil) {
        _accountSettingsVC = [[AMAccountSettingsVC alloc] init];
    }
    
    if(_accountSettingsVC){
        [tabView addConstrainsToSubview:_accountSettingsVC.view
                           leadingSpace:0 trailingSpace:0 topSpace:0 bottomSpace:0];
    }
}


-(void)registerTabButtons
{
    super.tabs=self.tabs;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.generalTabBtn];
    [self.tabButtons addObject:self.jackTabBtn];
    [self.tabButtons addObject:self.jacktripTabBtn];
    [self.tabButtons addObject:self.oscGroupTabBtn];
    [self.tabButtons addObject:self.accountTabBtn];
    [self.tabButtons addObject:self.videoTabBtn];
    self.showingTabsCount=6;
}

- (IBAction)onGeneralClick:(id)sender {
    [self pushDownButton:self.generalTabBtn];
    [self.tabs selectTabViewItemAtIndex:0];
}

- (IBAction)onJackClick:(id)sender {
    [self pushDownButton:self.jackTabBtn];
    [self.tabs selectTabViewItemAtIndex:1];
}


- (IBAction)onJackTripClick:(id)sender {
    [self pushDownButton:self.jacktripTabBtn];
    [self.tabs selectTabViewItemAtIndex:2];
}

- (IBAction)onVideoClick:(id)sender {
    [self pushDownButton:self.videoTabBtn];
    [self.tabs selectTabViewItemAtIndex:3];
}

- (IBAction)onOSCGroupClick:(id)sender {
    [self pushDownButton:self.oscGroupTabBtn];
    [self.tabs selectTabViewItemAtIndex:4];
}

- (IBAction)onAccountClick:(id)sender {
    [self pushDownButton:self.accountTabBtn];
    [self.tabs selectTabViewItemAtIndex:5];
}

- (void) changeTheme:(NSNotification *) notification {
    
    [super changeTheme:notification];
    
    //Update text properties
    self.curTheme = [AMTheme sharedInstance];
    
    self.textColor = self.curTheme.colorTextPanelTab;
    self.textColorSelected = self.curTheme.colorTextPanelTabSelected;
}

@end
