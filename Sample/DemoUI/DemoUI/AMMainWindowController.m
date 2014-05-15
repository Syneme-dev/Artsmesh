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
#import "AMSocialViewController.h"
#import "AMUserGroupViewController.h"
#import <UIFramework/BlueBackgroundView.h>
#import "AMChatViewController.h"
#import "AMPingViewController.h"


#define UI_leftSidebarWidth 40.0f
#define UI_panelSpacing 30.0f
#define UI_defaultPanelWidth 300.0f
#define UI_topbarHeight 40.0f
#define UI_panelPaddingBottom 10.0f
#define UI_pixelHeightAdjustment 2.0f
#define UI_panelTitlebarHeight 20.0f
#define UI_panelContentPaddingBottom 20.0f
#define UI_appleMenuBarHeight 20.0f



@interface AMMainWindowController ()


@end

@implementation AMMainWindowController
{
    AMUserGroupViewController *_userGroupViewController;
    NSView *_containerView;
    AMETCDPreferenceViewController *preferenceViewController;
    AMSocialViewController * socialViewController;
//    AMPanelViewController *preferencePanelController;
//    AMPanelViewController *userPanelController;
//    AMPanelViewController *groupsPanelController;
//    AMPanelViewController *socialPanelController;
    AMChatViewController *chatViewController;
    AMPingViewController *pingViewController;
//    AMPanelViewController *chatPanelController;
    NSMutableDictionary *panelControllers;
    float containerWidth;
}
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        panelControllers=[[NSMutableDictionary alloc] init];
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

-(void)loadVersion{
    NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    [self.versionLabel setStringValue:[NSString stringWithFormat:@"%@.%@",shortVersion,buildVersion]];
}

-(void)awakeFromNib{

}

- (void)showDefaultWindow {
    
    NSRect screenSize = [[NSScreen mainScreen] frame];
    //Note:code make the window max size.
    //[self.window setFrame:screenSize display:YES ];
    [self.window setFrameOrigin:NSMakePoint(0.0f, screenSize.size.height - UI_appleMenuBarHeight)];
    NSScrollView *scrollView = [[self.window.contentView subviews] objectAtIndex:0];
    _containerView = [[NSView alloc] initWithFrame:NSMakeRect(0, self.window.frame.origin.y, 10000.0f, self.window.frame.size.height-UI_topbarHeight)];
    [scrollView setDocumentView:_containerView];
    [self loadVersion];
    [self loadPreferencePanel];
    [self loadGroupsPanel];
    [self loadUserPanel];
    containerWidth=
    UI_leftSidebarWidth+UI_panelSpacing+UI_defaultPanelWidth
    +UI_panelSpacing+2*UI_defaultPanelWidth+UI_panelSpacing ;
    [self loadChatPanel];
    [self loadPingPanel];
    
    //Note:using the following code to render FOAF panel.
  //  [self loadFOAFPanel];
    
    
}

-(void)createEmptyPanel:(NSString*) identifier withTitle:(NSString*)title{
    if (panelControllers[identifier]!=nil) {
        AMPanelViewController *panelViewController=panelControllers[identifier];
        [panelViewController.view setHidden:NO];

    }
    else
    {
        AMPanelViewController *panelViewController=
        [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
        float panelHeight=720.0f;
        panelViewController.view.frame = NSMakeRect(containerWidth,
                                                    self.window.frame.size.height-UI_topbarHeight-
                                                    panelHeight+UI_pixelHeightAdjustment, UI_defaultPanelWidth, panelHeight);
        [panelViewController setTitle:title];
        [_containerView addSubview:panelViewController.view];
        containerWidth+=panelViewController.view.frame.size.width+UI_panelSpacing;
        [panelControllers setObject:panelViewController forKey:identifier];
    }
    

}

-(void)loadFOAFPanel{
    AMPanelViewController *panelViewController = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    float panelHeight=720.0f;
    panelViewController.view.frame = NSMakeRect(containerWidth,
                                                  self.window.frame.size.height-UI_topbarHeight-
                                                  panelHeight+UI_pixelHeightAdjustment, UI_defaultPanelWidth*2, panelHeight);
    socialViewController = [[AMSocialViewController alloc] initWithNibName:@"AMSocialView" bundle:nil];
    socialViewController.view.frame = NSMakeRect(0, UI_panelContentPaddingBottom, UI_defaultPanelWidth*2, panelHeight-UI_panelTitlebarHeight-UI_panelContentPaddingBottom);
    [panelViewController.view addSubview:socialViewController.view];
    [panelViewController setTitle:@"SOCIAL"];
    [socialViewController.socialWebTab setFrameLoadDelegate:socialViewController];
    
    [socialViewController.socialWebTab setDrawsBackground:NO];
    [_containerView addSubview:panelViewController.view];
    containerWidth+=panelViewController.view.frame.size.width+UI_panelSpacing;
    [socialViewController loadPage];
    [panelControllers setObject:panelViewController forKey:@"SOCIAL"];
}



- (void)loadGroupsPanel {
    AMPanelViewController *panelViewController = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
   // panelViewController.view.frame = NSMakeRect(70.0f, self.window.frame.origin.y+self.window.frame.size.height-40.0f-300.0f-10-400-20, 300.0f, 400.0f);
    panelViewController.view.frame = NSMakeRect(70.0f, self.window.frame.size.height-40.0f-300.0f-10-400-20, 300.0f, 400.0f);
    _userGroupViewController = [[AMUserGroupViewController alloc] initWithNibName:@"AMUserGroupView" bundle:nil];
    _userGroupViewController.view.frame = NSMakeRect(0, 0, 300, 380);
    [panelViewController.view addSubview:_userGroupViewController.view];
    [panelViewController setTitle:@"GROUPS"];
    [_containerView addSubview:panelViewController.view];
    [panelControllers setObject:panelViewController forKey:@"GROUPS"];
}

- (void)loadPreferencePanel {
    AMPanelViewController *panelViewController = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    [_containerView addSubview:panelViewController.view];
    [panelViewController.titleView setStringValue:@"PREFERENCE"];
    panelViewController.view.frame = NSMakeRect(
                                                      UI_leftSidebarWidth+UI_panelSpacing+UI_defaultPanelWidth+UI_panelSpacing,
                                                     UI_panelPaddingBottom, 600.0f, 720.0f);
    preferenceViewController = [[AMETCDPreferenceViewController alloc] initWithNibName:@"AMETCDPreferenceView" bundle:nil];
    preferenceViewController.view.frame = NSMakeRect(0, 400, 600, 300);
    [panelViewController.view addSubview:preferenceViewController.view];
    [preferenceViewController loadSystemInfo];
    [preferenceViewController customPrefrence];
    [panelControllers setObject:panelViewController forKey:@"PREFERENCE"];

}

- (void)loadChatPanel {
    AMPanelViewController *panelViewController  = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    [_containerView addSubview:panelViewController.view];
    [panelViewController setTitle:@"CHAT"];
    panelViewController.view.frame = NSMakeRect(
                                                UI_leftSidebarWidth+UI_panelSpacing+UI_defaultPanelWidth+UI_panelSpacing+UI_defaultPanelWidth*2+UI_panelSpacing,
                                                UI_panelPaddingBottom, 600.0f, 720.0f);
    
    chatViewController = [[AMChatViewController alloc] initWithNibName:@"AMChatView" bundle:nil];
    chatViewController.view.frame = NSMakeRect(0, 100, 600, 600);
    [panelViewController.view addSubview:chatViewController.view];
    
    containerWidth+=panelViewController.view.frame.size.width+UI_panelSpacing;
     [panelControllers setObject:panelViewController forKey:@"CHAT"];
}

-(void)loadPingPanel{
    AMPanelViewController *panelViewController  = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    [_containerView addSubview:panelViewController.view];
    [panelViewController setTitle:@"PING"];
    panelViewController.view.frame = NSMakeRect(
                                                UI_leftSidebarWidth+UI_panelSpacing+UI_defaultPanelWidth+UI_panelSpacing+UI_defaultPanelWidth*4+UI_panelSpacing*2,
                                                UI_panelPaddingBottom, 600.0f, 720.0f);
    
    pingViewController = [[AMPingViewController alloc] initWithNibName:@"AMPingView" bundle:nil];
    pingViewController.view.frame = NSMakeRect(0, 100, 600, 600);
    [panelViewController.view addSubview:pingViewController.view];
    
    containerWidth+=panelViewController.view.frame.size.width+UI_panelSpacing;
    [panelControllers setObject:panelViewController forKey:@"PING"];
}



- (void)loadUserPanel {
    float panelHeight=300.0f;
    AMPanelViewController *panelViewController = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    panelViewController.view.frame = NSMakeRect(70.0f,self.window.frame.size.height-UI_topbarHeight-
                                                panelHeight+UI_pixelHeightAdjustment,  UI_defaultPanelWidth, panelHeight);
    
//  the following code for iMac
//    panelViewController.view.frame = NSMakeRect(70.0f,self.window.frame.size.height-UI_topbarHeight-
//                                                  panelHeight - UI_panelTitlebarHeight,  UI_defaultPanelWidth, panelHeight);
    [_containerView addSubview:panelViewController.view];
    [panelViewController setTitle:@"USER"];
    AMUserViewController *userViewController = [[AMUserViewController alloc] initWithNibName:@"AMUserView" bundle:nil];
    userViewController.view.frame = NSMakeRect(0, 0, 300, 300);
    [panelViewController.view addSubview:userViewController.view];
     [panelControllers setObject:panelViewController forKey:@"USER"];
    
}

- (IBAction)onSidebarItemClick:(NSButton *)sender {
    if(sender.state==NSOnState)
    {
        [self createEmptyPanel:sender.identifier withTitle:sender.identifier];
    }
    else
    {
        AMPanelViewController* pannelViewController=panelControllers[sender.identifier];
        [pannelViewController closePanel:nil];
    }
}
@end
