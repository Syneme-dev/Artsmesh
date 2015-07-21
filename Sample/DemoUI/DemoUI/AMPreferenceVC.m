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
#import "AMStatusNetSettingsVC.h"
#import "AMOSCGroupSettingsVC.h"
#import "AMJacktripSettingsVC.h"
#import "AMGeneralSettingsVC.h"
#import "UIFramework/NSView_Constrains.h"
#import "AMGoogleSettingsVC.h"


@interface AMPreferenceVC ()
@end

@implementation AMPreferenceVC
{
    dispatch_queue_t _preference_queue;
    
    NSViewController    *_generalSettingsVC;
    NSViewController    *_oscGroupSettingsVC;
    NSViewController    *_jacktripSettingVC;
    NSViewController    *_jackSettingsVC;
    NSViewController    *_statusNetSettingsVC;
    NSViewController    *_googleSettingsVC;
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
    [AMButtonHandler changeTabTextColor:self.statusnetTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.googleTabBtn toColor:UI_Color_blue];
    
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
            [self loadStatusNetPage:view ];
        }else if([view.identifier isEqualTo:@"google"]){
            [self loadGooglePage:view ];
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

-(void)loadGooglePage:(NSView*)tabView
{
    if (_googleSettingsVC == nil) {
        _googleSettingsVC = [[AMGoogleSettingsVC alloc] init];
    }
    
    if(_googleSettingsVC){
        [tabView addConstrainsToSubview:_googleSettingsVC.view
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
    [self.tabButtons addObject:self.statusnetTabButton];
    [self.tabButtons addObject:self.googleTabBtn];
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


- (IBAction)onOSCGroupClick:(id)sender {
    [self pushDownButton:self.oscGroupTabBtn];
    [self.tabs selectTabViewItemAtIndex:3];
}


- (IBAction)onStatusNetClick:(id)sender {
    [self pushDownButton:self.statusnetTabButton];
    [self.tabs selectTabViewItemAtIndex:4];
}

- (IBAction)onGoogleClick:(id)sender {
    [self pushDownButton:self.googleTabBtn];
    [self.tabs selectTabViewItemAtIndex:5];
}



@end
