//
//  AMMainWindowController.m
//  DemoUI
//
//  Created by xujian on 4/17/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMMainWindowController.h"

#import "AMMesher/AMMesher.h"


#import <AMPluginLoader/AMPluginAppDelegateProtocol.h>
#import "AMAppDelegate.h"
#import <AMPluginLoader/AMPluginProtocol.h>
#import <AMNotificationManager/AMNotificationManager.h>
#import <AMPreferenceManager/AMPreferenceManager.h>
#import "HelloWorldConst.h"
#import "AMPanelViewController.h"
#import "UserGroupModuleConst.h"
#import "AMMesher/AMMesher.h"
#import "AMETCDPreferenceViewController.h"
#import "AMUserViewController.h"
#import "AMUserGroupViewController.h"
#import <UIFramewrok/BlueBackgroundView.h>

#define UI_leftSidebarWidth 40.0f
#define UI_panelSpacing 30.0f
#define UI_defaultPanelWidth 300.0f
#define UI_topbarHeight 40.0f
#define UI_panelPaddingBottom 10.0f
#define UI_pixelHeightAdjustment 2.0f
@interface AMMainWindowController ()


@end

@implementation AMMainWindowController
{
    AMUserGroupViewController *_userGroupViewController;
    NSView *_containerView;
    AMETCDPreferenceViewController *preferenceViewController;
    AMPanelViewController *preferencePanelController;
    AMPanelViewController *userPanelController;
    AMPanelViewController *groupsPanelController;
    float containerWidth;
}
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (IBAction)mesh:(id)sender {
    [[AMMesher sharedAMMesher] everyoneGoOnline];
}


- (void)showDefaultWindow {
    
    NSRect screenSize = [[NSScreen mainScreen] frame];
    //Note:code make the window max size.
    [self.window setFrame:screenSize display:YES ];
    float appleMenuBarHeight = 20.0f;
    [self.window setFrameOrigin:NSMakePoint(0.0f, screenSize.size.height - appleMenuBarHeight)];
    NSScrollView *scrollView = [[self.window.contentView subviews] objectAtIndex:0];
    _containerView = [[NSView alloc] initWithFrame:NSMakeRect(0, self.window.frame.origin.y, 10000.0f, self.window.frame.size.height-40)];
    [scrollView setDocumentView:_containerView];
    [self loadGroupsPanel];
    [self loadPreferencePanel];
    [self loadUserPanel];
    containerWidth=
    UI_leftSidebarWidth+UI_panelSpacing+UI_defaultPanelWidth
    +UI_panelSpacing+2*UI_defaultPanelWidth+UI_panelSpacing ;
}

-(void)loadFOAFPanel{
    groupsPanelController = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    float panelHeight=400.0f;
    groupsPanelController.view.frame = NSMakeRect(containerWidth,
                                                  self.window.frame.size.height-UI_topbarHeight-
                                                  panelHeight+UI_pixelHeightAdjustment, UI_defaultPanelWidth, panelHeight);
    _userGroupViewController = [[AMUserGroupViewController alloc] initWithNibName:@"AMUserView" bundle:nil];
    _userGroupViewController.view.frame = NSMakeRect(0, 0, 300, 380);
    [groupsPanelController.view addSubview:_userGroupViewController.view];
    [groupsPanelController.titleView setStringValue:@"Groups"];
    [_containerView addSubview:groupsPanelController.view];
    containerWidth+=groupsPanelController.view.frame.size.width+UI_panelSpacing;

}



- (void)loadGroupsPanel {
    groupsPanelController = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    groupsPanelController.view.frame = NSMakeRect(70.0f, self.window.frame.origin.y+self.window.frame.size.height-40.0f-300.0f-10-400-20, 300.0f, 400.0f);
    _userGroupViewController = [[AMUserGroupViewController alloc] initWithNibName:@"AMUserGroupView" bundle:nil];
    _userGroupViewController.view.frame = NSMakeRect(0, 0, 300, 380);
    [groupsPanelController.view addSubview:_userGroupViewController.view];
    [groupsPanelController.titleView setStringValue:@"Groups"];
    [_containerView addSubview:groupsPanelController.view];
}

- (void)loadPreferencePanel {
    preferencePanelController = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    [_containerView addSubview:preferencePanelController.view];
    [preferencePanelController.titleView setStringValue:@"Preference"];
    preferencePanelController.view.frame = NSMakeRect(
                                                      UI_leftSidebarWidth+UI_panelSpacing+UI_defaultPanelWidth+UI_panelSpacing,
                                                     UI_panelPaddingBottom, 600.0f, 720.0f);
    preferenceViewController = [[AMETCDPreferenceViewController alloc] initWithNibName:@"AMETCDPreferenceView" bundle:nil];
    preferenceViewController.view.frame = NSMakeRect(0, 400, 600, 300);
    [preferencePanelController.view addSubview:preferenceViewController.view];
}

- (void)loadUserPanel {
    float panelHeight=300.0f;
    userPanelController = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    userPanelController.view.frame = NSMakeRect(70.0f,self.window.frame.size.height-UI_topbarHeight-
                                                panelHeight+UI_pixelHeightAdjustment,  UI_defaultPanelWidth, panelHeight);
    [_containerView addSubview:userPanelController.view];
    [userPanelController.titleView setStringValue:@"User"];
    AMUserViewController *userViewController = [[AMUserViewController alloc] initWithNibName:@"AMUserView" bundle:nil];
    userViewController.view.frame = NSMakeRect(0, 0, 300, 300);
    [userPanelController.view addSubview:userViewController.view];
    
}

@end
