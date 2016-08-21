//
//  AMPanelControlBarViewController.h
//  DemoUI
//
//  Created by xujian on 7/23/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMControlBarButtonResponder.h"
#import "UIFramework/AMTheme.h"

@interface AMPanelControlBarViewController : NSViewController


@property (strong) IBOutlet AMControlBarButtonResponder *panelUserBtn;
@property (strong) IBOutlet AMControlBarButtonResponder *panelUserBtnSidebar;

@property (strong) IBOutlet AMControlBarButtonResponder *panelGroupBtn;
@property (strong) IBOutlet AMControlBarButtonResponder *panelGroupBtnSidebar;


@property (strong) IBOutlet AMControlBarButtonResponder *panelChatBtn;
@property (strong) IBOutlet AMControlBarButtonResponder *panelChatBtnSidebar;


@property (strong) IBOutlet AMControlBarButtonResponder *panelSocialBtn;
@property (strong) IBOutlet AMControlBarButtonResponder *panelSocialBtnSidebar;


@property (strong) IBOutlet AMControlBarButtonResponder *panelMapBtn;
@property (strong) IBOutlet AMControlBarButtonResponder *panelMapBtnSidebar;


@property (strong) IBOutlet AMControlBarButtonResponder *panelRouteBtn;
@property (strong) IBOutlet AMControlBarButtonResponder *panelRouteBtnSidebar;


@property (strong) IBOutlet AMControlBarButtonResponder *panelVideoBtn;
@property (strong) IBOutlet AMControlBarButtonResponder *panelVideoBtnSidebar;

@property (strong) IBOutlet AMControlBarButtonResponder *panelMusicBtn;
@property (strong) IBOutlet AMControlBarButtonResponder *panelMusicBtnSidebar;


@property (strong) IBOutlet AMControlBarButtonResponder *panelClockBtn;
@property (strong) IBOutlet AMControlBarButtonResponder *panelClockBtnSidebar;


@property (strong) IBOutlet AMControlBarButtonResponder *panelOSCBtn;
@property (strong) IBOutlet AMControlBarButtonResponder *panelOSCBtnSidebar;


@property (strong) IBOutlet AMControlBarButtonResponder *panelTerminalBtn;
@property (strong) IBOutlet AMControlBarButtonResponder *panelTerminalBtnSidebar;


@property (strong) IBOutlet AMControlBarButtonResponder *panelSettingsBtn;
@property (strong) IBOutlet AMControlBarButtonResponder *panelSettingsBtnSidebar;


@property (strong) IBOutlet AMControlBarButtonResponder *panelHelpBtn;
@property (strong) IBOutlet AMControlBarButtonResponder *panelHelpBtnSidebar;

@property (strong) IBOutlet AMControlBarButtonResponder *panelBroadcastBtn;
@property (strong) IBOutlet AMControlBarButtonResponder *panelBroadcastBtnSidebar;



@property AMTheme *curTheme;

- (IBAction)onSidebarItemClick:(NSButton *)sender ;


- (IBAction)onSidebarDoubleClick:(NSButton *)sender ;
@end
