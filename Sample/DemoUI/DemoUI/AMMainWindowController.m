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
#import "AMETCDPreferenceViewController.h"
#import "AMUserViewController.h"
#import "AMSocialViewController.h"
#import "AMUserGroupViewController.h"
#import <UIFramework/BlueBackgroundView.h>
#import "AMChatViewController.h"
#import "AMPingViewController.h"
#import "UIFramework/AMBox.h"
#import "UIFramework/AMPanelView.h"


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
    AMBox *_containerView;
    AMETCDPreferenceViewController *preferenceViewController;
    AMSocialViewController * socialViewController;
    AMChatViewController *chatViewController;
    AMPingViewController *pingViewController;
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
    
    AMMesher* mesher = [AMMesher sharedAMMesher];
//    if (mesher.isOnline == NO) {
//        [mesher goOnline ];
//    }else{
//        [mesher goOffline];
//    }
}

-(void)loadVersion{
    NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    [self.versionLabel setStringValue:[NSString stringWithFormat:@"%@.%@",shortVersion,buildVersion]];
}

-(void)awakeFromNib{

}

- (void)showDefaultWindow {
    
    NSSize windowSize = [self.window.contentView frame].size;
    //Note:code make the window max size.
    //[self.window setFrame:screenSize display:YES ];
//    [self.window setFrameOrigin:NSMakePoint(0.0f, screenSize.size.height - UI_appleMenuBarHeight)];
    NSScrollView *scrollView = [[self.window.contentView subviews] objectAtIndex:0];
    scrollView.frame = NSMakeRect(UI_leftSidebarWidth,
                                  0,
                                  windowSize.width - UI_leftSidebarWidth,
                                  windowSize.height - UI_topbarHeight);
    
    _containerView = [AMBox hbox];
    _containerView.frame = scrollView.bounds;
    _containerView.paddingLeft = 40;
    _containerView.paddingRight = 50;
    _containerView.minSizeConstraint = _containerView.frame.size;
    _containerView.allowBecomeEmpty = YES;
    _containerView.gapBetweenItems = 50;
    CGFloat contentHeight = _containerView.frame.size.height;
     _containerView.prepareForAdding = ^(AMBoxItem *boxItem) {
         if ([boxItem isKindOfClass:[AMBox class]])
             return (AMBox *)nil;
         AMBox *newBox = [AMBox vbox];
         newBox.minSizeConstraint = NSMakeSize(0, contentHeight);
         newBox.paddingTop = 20;
         newBox.paddingBottom = 20;
         newBox.paddingLeft = 6;
         newBox.paddingRight = 0;
         newBox.gapBetweenItems = 40;
         [newBox addSubview:boxItem];
         return newBox;
     };
    [scrollView setDocumentView:_containerView];
    
    [self loadVersion];
    [self loadUserPanel];
    [self loadGroupsPanel];
    [self loadPreferencePanel];
    [self loadChatPanel];
    [self loadPingPanel];
    [self loadFOAFPanel];

    /*
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
    [self loadFOAFPanel];
    */
    
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
    
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize panelSize = NSMakeSize(UI_defaultPanelWidth*2, 740);
    [panelView setFrameSize:panelSize];
    panelView.minSizeConstraint = panelSize;
    panelView.maxSizeConstraint = panelSize;
    [_containerView addSubview:panelView];
    socialViewController = [[AMSocialViewController alloc] initWithNibName:@"AMSocialView" bundle:nil];
    socialViewController.view.frame = NSMakeRect(0, UI_panelContentPaddingBottom, UI_defaultPanelWidth*2, panelSize.height-UI_panelTitlebarHeight-UI_panelContentPaddingBottom);
    [panelViewController.view addSubview:socialViewController.view];
    [panelViewController setTitle:@"SOCIAL"];
    [socialViewController.socialWebTab setFrameLoadDelegate:socialViewController];
      [socialViewController.socialWebTab setPolicyDelegate:socialViewController];
    
    [socialViewController.socialWebTab setDrawsBackground:NO];
//    [_containerView addSubview:panelViewController.view];
    containerWidth+=panelViewController.view.frame.size.width+UI_panelSpacing;
    [socialViewController loadPage];
    [panelControllers setObject:panelViewController forKey:@"SOCIAL"];
}

- (void)loadGroupsPanel {
    AMPanelViewController *panelViewController = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize panelSize = NSMakeSize(300.0f, 400.0f);
    [panelView setFrameSize:panelSize];
    panelView.minSizeConstraint = panelSize;
    NSSize maxSize = NSMakeSize(600.0f, 740.0f);
    panelView.maxSizeConstraint = maxSize;
    [_containerView addSubview:panelView];
    _userGroupViewController = [[AMUserGroupViewController alloc] initWithNibName:@"AMUserGroupView" bundle:nil];
    _userGroupViewController.view.frame = NSMakeRect(0, UI_panelTitlebarHeight, 300, 380);
     NSView *groupView = _userGroupViewController.view;
    [panelViewController.view addSubview:groupView];
    
    [groupView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(groupView);
    [panelView addConstraints:        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[groupView]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]];
    
    [panelView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-21-[groupView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    
    
    [panelViewController setTitle:@"GROUPS"];
    [panelControllers setObject:panelViewController forKey:@"GROUPS"];
}

- (void)loadPreferencePanel {
    AMPanelViewController *panelViewController = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize panelSize = NSMakeSize(600.0f, 300);
    [panelView setFrameSize:panelSize];
    panelView.minSizeConstraint = panelSize;
    panelView.maxSizeConstraint = panelSize;
    [_containerView addSubview:panelView];
    [panelViewController.titleView setStringValue:@"PREFERENCE"];
    preferenceViewController = [[AMETCDPreferenceViewController alloc] initWithNibName:@"AMETCDPreferenceView" bundle:nil];
    preferenceViewController.view.frame = NSMakeRect(0, UI_panelTitlebarHeight, 600, 270);
    NSView *preferenceView = preferenceViewController.view;
    [panelViewController.view addSubview:preferenceViewController.view];
    [preferenceViewController loadSystemInfo];
    [preferenceViewController customPrefrence];
    [panelControllers setObject:panelViewController forKey:@"PREFERENCE"];
    
    [preferenceView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(preferenceView);
    [panelView addConstraints:        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[preferenceView]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]];
    
    [panelView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-21-[preferenceView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];

    

}

- (void)loadChatPanel {
    AMPanelViewController *panelViewController  = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize panelSize = NSMakeSize(600.0f, 740.0f);
    [panelView setFrameSize:panelSize];
    panelView.minSizeConstraint = NSMakeSize(600.0f, 300.0f);
    panelView.maxSizeConstraint = panelSize;
    [_containerView addSubview:panelView];
    [panelViewController setTitle:@"CHAT"];
    chatViewController = [[AMChatViewController alloc] initWithNibName:@"AMChatView" bundle:nil];
    chatViewController.view.frame = NSMakeRect(0, UI_panelTitlebarHeight, 600, 650);
    NSView *chatView = chatViewController.view;
    [panelViewController.view addSubview:chatView];
    
    [chatView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(chatView);
    [panelView addConstraints:        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[chatView]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]];
    
    [panelView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-21-[chatView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    containerWidth+=panelViewController.view.frame.size.width+UI_panelSpacing;
     [panelControllers setObject:panelViewController forKey:@"CHAT"];
}

-(void)loadPingPanel{
    AMPanelViewController *panelViewController  = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize panelSize = NSMakeSize(600.0f, 400);
    [panelView setFrameSize:panelSize];
    NSSize maxSize = NSMakeSize(600.0f, 740);
    NSSize minSize = NSMakeSize(600.0f, 300);
    panelView.maxSizeConstraint = maxSize;
    panelView.minSizeConstraint = minSize;
    [_containerView addSubview:panelView];
    [panelViewController setTitle:@"PING"];
    pingViewController = [[AMPingViewController alloc] initWithNibName:@"AMPingView" bundle:nil];
    NSView *pingView = pingViewController.view;
    pingView.frame = NSMakeRect(0, UI_panelTitlebarHeight, 600, 380);
    [panelView addSubview:pingView];
    
    [pingView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(pingView);
    [panelView addConstraints:        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pingView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [panelView addConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-21-[pingView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    containerWidth+=panelViewController.view.frame.size.width+UI_panelSpacing;
    [panelControllers setObject:panelViewController forKey:@"PING"];
}

- (void)loadUserPanel {
    
    float panelHeight=300.0f;
    AMPanelViewController *panelViewController = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize panelSize = NSMakeSize(UI_defaultPanelWidth, panelHeight);
    [panelView setFrameSize:panelSize];
    panelView.minSizeConstraint = panelSize;
    panelView.maxSizeConstraint = panelSize;
    [_containerView addSubview:panelView];
    [panelViewController setTitle:@"USER"];
    AMUserViewController *userViewController = [[AMUserViewController alloc] initWithNibName:@"AMUserView" bundle:nil];
    userViewController.view.frame = NSMakeRect(0, UI_panelTitlebarHeight, UI_defaultPanelWidth, panelHeight-UI_panelTitlebarHeight);
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

-(void)setSideBarItemStatus:(NSString *) identifier withStatus:(Boolean)status{
    NSView *mainView= self.window.contentView;
    for (NSView *subView in mainView.subviews) {
        if([subView isKindOfClass:[BlueBackgroundView class]] )
        {
            NSButton *buttonView= subView.subviews[0];
            if(buttonView !=nil&& [buttonView.identifier  isEqualTo:identifier])
            {
                [buttonView setState:status?NSOnState:NSOffState];
                break;
            }
        }
    }


}
@end
