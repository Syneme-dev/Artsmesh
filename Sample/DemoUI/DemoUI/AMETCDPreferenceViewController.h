//
//  AMETCDPreferenceViewController.h
//  DemoUI
//
//  Created by 王 为 on 3/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AMETCDPreferenceViewController : NSViewController
@property (retain) IBOutlet NSTabView *tabs;

@property  IBOutlet NSView *progressView;

@property (weak) IBOutlet NSTextField *myMachineNameField;
@property (weak) IBOutlet NSPopUpButton *myPrivateIpPopup;
@property (weak) IBOutlet NSTextField *statusNetPostTestResult;
@property (weak) IBOutlet NSButton *testStatusNetPost;

@property (strong) IBOutlet NSButton *generalTabButton;
@property (strong) IBOutlet NSButton *jackServerTabButton;

@property (strong) IBOutlet NSButton *jackRouterTabButton;
@property (strong) IBOutlet NSButton *videoTabButton;
@property (strong) IBOutlet NSButton *audioTabButton;
@property (strong) IBOutlet NSButton *statusnetTabButton;

- (IBAction)onJackServerTabClick:(id)sender;
- (IBAction)onGeneralClick:(id)sender;
- (IBAction)onStatusNetClick:(id)sender;

- (IBAction)privateIpSelected:(id)sender;
- (IBAction)statusNetTest:(id)sender;

-(void)loadSystemInfo;
-(void)customPrefrence;


@end
