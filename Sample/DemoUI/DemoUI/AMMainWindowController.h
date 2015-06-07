//
//  AMMainWindowController.h
//  DemoUI
//
//  Created by xujian on 4/17/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMPanelViewController.h"
#import "AMJackCPULoderView.h"

@class AMFoundryFontView;

@interface AMMainWindowController : NSWindowController<NSWindowDelegate>
@property (weak) IBOutlet NSButton *meshBtn;

- (IBAction)mesh:(id)sender;
- (void)showDefaultWindow ;
@property NSMutableDictionary *panelControllers;
@property (weak) IBOutlet NSTextField *versionLabel;
- (IBAction)onSidebarItemClick:(NSButton *)sender;
@property(nonatomic, readonly) NSView *containerView;
@property (weak) IBOutlet NSButton *jackServerBtn;
@property (weak) IBOutlet NSButton *oscServerBtn;
@property (weak) IBOutlet NSButton *syphonServerBtn;
@property (weak) IBOutlet AMJackCPULoderView *jackCPUUsageBar;
@property (weak) IBOutlet AMFoundryFontView *jackCpuUageNum;

@property (weak) IBOutlet NSScrollView *mainScrollView;


@property (nonatomic) NSTimer* blinkBackTimer;

-(void)setSideBarItemStatus:(NSString *) identifier withStatus:(Boolean)status;

- (IBAction)copyPanel:(id)sender;

-(void)loadControlBar;

-(void)removePanel:(NSString *)panelName;
-(AMPanelViewController *)createPanelWithType:(NSString*)panelType withId:(NSString*)panelId;

-(void)createTabPanelWithType:(NSString*)panelType withTitle:(NSString*)title withPanelId:(NSString*)panelId withTabIndex:(NSInteger)tabIndex from:(AMPanelViewController*)fromController;


//Error handler
//@property (assign)IBOutlet NSWindow *errorHandleSheet;
//@property (weak) IBOutlet NSTextField *localServerIpv4;
//@property (weak)IBOutlet NSTextField *localServerIpv6;

//-(IBAction)sheetOKBtnClicked:(id)sender;
//-(IBAction)sheetCancelBtnClicked:(id)sender;

@end
