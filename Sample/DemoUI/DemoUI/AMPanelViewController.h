//
//  AMPanelViewController.h
//  DemoUI
//
//  Created by xujian on 3/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMTabPanelViewController.h"

typedef NS_ENUM(NSUInteger, AMPanelViewType) {
    AMNetworkToolsPanelType = 1
};

@interface AMPanelViewController : NSViewController <NSWindowDelegate>
@property (strong) IBOutlet NSButton *tearOffButton;
@property (strong) IBOutlet NSButton *settingButton;
@property (strong) IBOutlet NSButton *tabPanelButton;
@property (strong) IBOutlet NSButton *maxSizeButton;
@property (strong) IBOutlet NSButton *fullScreenButton;
@property (weak) IBOutlet NSButton *closeButton;

- (IBAction)onTearClick:(id)sender;
- (IBAction)onCopyTabButtonClick:(id)sender;

@property(nonatomic) AMPanelViewType panelType;

@property(nonatomic) AMTabPanelViewController *tabPanelViewController;
@property(nonatomic) NSViewController *contentPanelViewController;
@property (nonatomic) NSString* panelId;
@property (strong) IBOutlet NSView *toolBarView;
@property  NSString *title;
@property(nonatomic) NSViewController *subViewController;

@property(strong)  AMPanelViewController *movedFromController;

@property (weak) IBOutlet NSTextField *titleView;
- (IBAction)closePanel:(id)sender;


-(void)reAttachTab:(NSInteger)tabIntex;

-(void)showAsTabPanel:(NSString*)tabTitle withTabIndex:(NSInteger)tabIndex;

@end
