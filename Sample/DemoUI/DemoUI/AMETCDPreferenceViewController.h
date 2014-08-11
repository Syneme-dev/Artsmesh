//
//  AMETCDPreferenceViewController.h
//  DemoUI
//
//  Created by 王 为 on 3/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <UIFramework/AMCheckBoxView.h>
#import "UIFramework/AMPopUpView.h"
#import "AMTabPanelViewController.h"


@interface AMETCDPreferenceViewController : AMTabPanelViewController
@property (retain) IBOutlet NSTabView *tabs;

@property  IBOutlet NSView *progressView;

@property (weak) IBOutlet NSTextField *myMachineNameField;
@property (weak) IBOutlet NSTextField *statusNetPostTestResult;
@property (weak) IBOutlet NSButton *testStatusNetPost;
@property (weak) IBOutlet AMPopUpView *ipPopUpView;

@property (strong) IBOutlet NSButton *generalTabButton;
@property (strong) IBOutlet NSButton *jackServerTabButton;

@property (strong) IBOutlet NSButton *jackRouterTabButton;
@property (strong) IBOutlet NSButton *videoTabButton;
@property (strong) IBOutlet NSButton *audioTabButton;
@property (strong) IBOutlet NSButton *statusnetTabButton;
@property (weak) IBOutlet NSButton *postStatusMessageButton;

- (IBAction)onJackServerTabClick:(id)sender;
- (IBAction)onGeneralClick:(id)sender;
- (IBAction)onStatusNetClick:(id)sender;

- (IBAction)statusNetTest:(id)sender;

@property (strong) IBOutlet AMCheckBoxView *isTopControlBarCheckBox;
-(void)loadSystemInfo;


@end
