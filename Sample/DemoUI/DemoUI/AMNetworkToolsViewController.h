//
//  AMNetworkToolsViewController.h
//  DemoUI
//
//  Created by lattesir on 8/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMTabPanelViewController.h"

@class AMLogReader;

@interface AMNetworkToolsViewController : AMTabPanelViewController<NSTableViewDelegate, NSTableViewDataSource>
- (IBAction)showErrorLog:(id)sender;
- (IBAction)showWarningLog:(id)sender;
- (IBAction)showInfoLog:(id)sender;
- (IBAction)showSysLog:(id)sender;

@property (weak) IBOutlet NSButton *pingButton;
@property (weak) IBOutlet NSButton *tracerouteButton;
@property (weak) IBOutlet NSButton *iperfButton;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSButton *logButton;


@property (weak) IBOutlet NSComboBox *chooseLogCombo;
@property (unsafe_unretained)   IBOutlet NSTextView*    logTextView;
@property (weak)                IBOutlet NSButton*      fullLog;

@property (weak) IBOutlet NSTableView *pingTableView;
@property (unsafe_unretained) IBOutlet NSTextView *pingContentView;

@property (weak) IBOutlet NSTableView *tracerouteTableView;
@property (unsafe_unretained) IBOutlet NSTextView *tracerouteContentView;

- (IBAction)ping:(id)sender;
- (IBAction)traceroute:(id)sender;
- (IBAction)iperf:(id)sender;
- (IBAction)log:(id)sender;



-(void) showLog;
-(void) showLogFromTail;
-(void) showFullLog;
-(void) handleNextLogTimer:(NSTimer*) timer;
@end
