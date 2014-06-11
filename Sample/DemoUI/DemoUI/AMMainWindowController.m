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
#import "AMTestViewController.h"
#import "AMMixingViewController.h"
#import "AMOSCRouteViewController.h"    
#import "AMVisualViewController.h"
#import "AMMapViewController.h"


#define UI_leftSidebarWidth 40.0f
#define UI_panelSpacing 30.0f
#define UI_defaultPanelWidth 300.0f

#define UI_defaultPanelHeight 720.0f
#define UI_topbarHeight 40.0f
#define UI_panelPaddingBottom 10.0f
#define UI_pixelHeightAdjustment 2.0f
#define UI_panelTitlebarHeight 20.0f
#define UI_panelContentPaddingBottom 20.0f
#define UI_appleMenuBarHeight 20.0f

#define UI_Panel_Key_User @"USER_PANEL"
#define UI_Panel_Key_Groups @"GROUPS_PANEL"
#define UI_Panel_Key_Preference @"PREFERENCE_PANEL"
#define UI_Panel_Key_Chat @"CHAT_PANEL"
#define UI_Panel_Key_NetworkTools @"NETWORKTOOLS_PANEL"
#define UI_Panel_Key_Mixing @"MIXING_PANEL"
#define UI_Panel_Key_Map @"MAP_PANEL"
#define UI_Panel_Key_Visual @"VISUAL_PANEL"




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
    AMTestViewController *testViewController;
    AMMapViewController *mapViewController;
    AMMixingViewController *mixingViewController;
    AMVisualViewController  *visualViewController;
    
    float containerWidth;
}
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        _panelControllers=[[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (IBAction)mesh:(id)sender {
    AMMesher* mesher = [AMMesher sharedAMMesher];
    if (mesher.isOnline == NO) {
        [mesher goOnline ];
    }else{
        [mesher goOffline];
    }
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
//    [[AMPreferenceManager instance] setObject:[[NSMutableArray alloc]init] forKey:UserData_Key_OpenedPanel];
    NSMutableArray *openedPanels=(NSMutableArray*)[[AMPreferenceManager instance] objectForKey:UserData_Key_OpenedPanel];
   [self loadTestPanel];
    if ([openedPanels containsObject:UI_Panel_Key_User]) {
        [self loadUserPanel];
    }
    
    if ([openedPanels containsObject:UI_Panel_Key_Groups]) {
        [self loadGroupsPanel];
    }
    if ([openedPanels containsObject:UI_Panel_Key_Preference]) {
        [self loadPreferencePanel];
        }
    if ([openedPanels containsObject:UI_Panel_Key_Chat]) {
    [self loadChatPanel];
    }
    if ([openedPanels containsObject:UI_Panel_Key_NetworkTools]) {

    [self loadNetworkToolsPanel];
    }
//    if ([openedPanels containsObject:UI_Panel_Key_F]) {

    [self loadFOAFPanel];
//    }
    
    if ([openedPanels containsObject:UI_Panel_Key_Map]) {
    [self loadMapPanel];
    }
    if ([openedPanels containsObject:UI_Panel_Key_Visual]) {
    [self loadVisualPanel];
    }
    if ([openedPanels containsObject:UI_Panel_Key_Mixing]) {
    [self loadMixingPanel];
    }
    for (NSString* openedPanel in openedPanels) {
        NSString *sideItemId=[openedPanel stringByReplacingOccurrencesOfString:@"_PANEL" withString:@""];
        [self setSideBarItemStatus:sideItemId withStatus:YES ];
    }
    
}
-(AMPanelViewController* )createPanel:(NSString*) identifier withTitle:(NSString*)title{
    AMPanelViewController *viewController=
    [self createPanel:identifier withTitle:title  width:UI_defaultPanelWidth height:UI_defaultPanelHeight];
    return viewController;
    
}

-(void)showPanel:(NSString*) identifier
{
   AMPanelViewController* panelViewController=self.panelControllers[identifier];
    [panelViewController.view setHidden:NO];
}

-(AMPanelViewController* )createPanel:(NSString*) identifier withTitle:(NSString*)title  width:(float)width height:(float)height{
    AMPanelViewController *panelViewController;
    
        panelViewController=
        [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    panelViewController.panelId=identifier;
        panelViewController.view.frame = NSMakeRect(0,
                                                    self.window.frame.size.height-UI_topbarHeight-
                                                    height+UI_pixelHeightAdjustment, width, height);
        [panelViewController setTitle:title];
        [_containerView addSubview:panelViewController.view  positioned:NSWindowBelow relativeTo:nil];
        containerWidth+=panelViewController.view.frame.size.width+UI_panelSpacing;
        [self.panelControllers setObject:panelViewController forKey:identifier];
        
    
    NSMutableArray *openedPanels=[[[AMPreferenceManager instance] objectForKey:UserData_Key_OpenedPanel] mutableCopy];
    if(![openedPanels containsObject:identifier])
    {
        [openedPanels addObject:identifier];
    }
    for (NSView *subView in _containerView.subviews) {
        if([subView isKindOfClass:[AMPanelView class]] )
        {
            [subView setFrameOrigin:NSMakePoint(subView.frame.origin.x+40.0+width, subView.frame.origin.y)];
        }
    }

    [[AMPreferenceManager instance] setObject:openedPanels forKey:UserData_Key_OpenedPanel];
    
    return panelViewController;
    

}

-(void)hidePanel:(NSString *)panelName{
    AMPanelViewController* pannelViewController=self.panelControllers[panelName];
    [pannelViewController closePanel:nil];
  
}


-(void)fillPanel:(NSView*) panelView content:(NSView*)contentView{
    NSSize panelSize = panelView.frame.size;
        contentView.frame = NSMakeRect(0, UI_panelContentPaddingBottom, panelSize.width, panelSize.height-UI_panelTitlebarHeight-UI_panelContentPaddingBottom);
        [panelView addSubview:contentView];
        [contentView setNeedsDisplay:YES];
}

-(void)loadTestPanel{
    AMPanelViewController* panelViewController=  [self createPanel:@"TEST_PANEL" withTitle:@"test"];
        testViewController = [[AMTestViewController alloc] initWithNibName:@"AMTestView" bundle:nil];
        [self fillPanel:panelViewController.view content:testViewController.view];
    }

-(void)loadMapPanel{
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_Map withTitle:@"Map" width:UI_defaultPanelWidth*4.0 height:UI_defaultPanelHeight ];
    mapViewController = [[AMMapViewController alloc] initWithNibName:@"AMMapViewController" bundle:nil];
    [self fillPanel:panelViewController.view content:mapViewController.view];
}

-(void)loadMixingPanel{
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_Mixing withTitle:@"Mixing" width:UI_defaultPanelWidth*4.0 height:UI_defaultPanelHeight ];
    mixingViewController = [[AMMixingViewController alloc] initWithNibName:@"AMMixingViewController" bundle:nil];
    [self fillPanel:panelViewController.view content:mixingViewController.view];
}

-(void)loadVisualPanel{
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_Visual withTitle:@"Visualization" width:UI_defaultPanelWidth*2.0 height:UI_defaultPanelHeight ];
    visualViewController = [[AMVisualViewController alloc] initWithNibName:@"AMVisualViewController" bundle:nil];
    [self fillPanel:panelViewController.view content:visualViewController.view];
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
    containerWidth+=panelViewController.view.frame.size.width+UI_panelSpacing;
    [socialViewController loadPage];
    [self.panelControllers setObject:panelViewController forKey:@"SOCIAL"];
}

- (void)loadGroupsPanel {
    float panelWidth=300.0f;
    float panelHeight=400.0f;
    AMPanelViewController *panelViewController=[self createPanel:UI_Panel_Key_Groups withTitle:@"GROUPS"
                                                           width:panelWidth height:panelHeight];
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize panelSize = NSMakeSize(300.0f, 400.0f);
    panelView.minSizeConstraint = panelSize;
//    NSSize maxSize = NSMakeSize(600.0f, 740.0f);
//    panelView.maxSizeConstraint = maxSize;

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
    
    
    


}

- (void)loadPreferencePanel {
    float panelWidth=600.0f;
    float panelHeight=300.0f;
    AMPanelViewController *panelViewController=[self createPanel:UI_Panel_Key_Preference withTitle:@"PREFERENCE"
                                                           width:panelWidth height:panelHeight];
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize panelSize = NSMakeSize(600.0f, 300);

    panelView.minSizeConstraint = panelSize;
    panelView.maxSizeConstraint = panelSize;


    preferenceViewController = [[AMETCDPreferenceViewController alloc] initWithNibName:@"AMETCDPreferenceView" bundle:nil];
    preferenceViewController.view.frame = NSMakeRect(0, UI_panelTitlebarHeight, 600, 270);
    NSView *preferenceView = preferenceViewController.view;
    [panelViewController.view addSubview:preferenceViewController.view];
    [preferenceViewController loadSystemInfo];
    [preferenceViewController customPrefrence];

    
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
    float panelWidth=600.0f;
    float panelHeight=740.0f;

    AMPanelViewController *panelViewController=[self createPanel:UI_Panel_Key_Chat withTitle:@"CHAT"
                                                           width:panelWidth height:panelHeight];
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
       NSSize maxPanelSize = NSMakeSize(600.0f, 740.0f);
    panelView.minSizeConstraint = NSMakeSize(600.0f, 300.0f);
    panelView.maxSizeConstraint = maxPanelSize;
    [panelViewController setTitle:@"CHAT"];
    chatViewController = [[AMChatViewController alloc] initWithNibName:@"AMChatView" bundle:nil];
    NSView *chatView = chatViewController.view;
    
    [self fillPanel:panelViewController.view content:chatViewController.view];
    
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
}

-(void)loadNetworkToolsPanel{
    float panelWidth=600.0f;
    float panelHeight=400.0f;
    AMPanelViewController *panelViewController=[self createPanel:UI_Panel_Key_NetworkTools withTitle:@"NETWORK TOOLS" width:panelWidth height:panelHeight];
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize maxSize = NSMakeSize(600.0f, 740);
    NSSize minSize = NSMakeSize(600.0f, 300);
    panelView.maxSizeConstraint = maxSize;
    panelView.minSizeConstraint = minSize;
    
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
    
    
    [self fillPanel:panelViewController.view content:pingViewController.view];
    
}

- (void)loadUserPanel {
    float panelHeight=300.0f;
    AMPanelViewController *panelViewController=[self createPanel:@"USER_PANEL" withTitle:@"USER" width:UI_defaultPanelWidth height:panelHeight];
        AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize panelSize = NSMakeSize(UI_defaultPanelWidth, panelHeight);
    panelView.minSizeConstraint = panelSize;
    panelView.maxSizeConstraint = panelSize;
    AMUserViewController *userViewController = [[AMUserViewController alloc] initWithNibName:@"AMUserView" bundle:nil];
    [self fillPanel:panelViewController.view content:userViewController.view];
}


- (IBAction)onSidebarItemClick:(NSButton *)sender {
    NSString *panelId=
    [[NSString stringWithFormat:@"%@_PANEL",sender.identifier ] uppercaseString];

    if(sender.state==NSOnState)
    {
        if ([panelId isEqualToString:UI_Panel_Key_User]) {
            [self loadUserPanel];
            }
        else if ([panelId isEqualToString:UI_Panel_Key_Groups]) {
            [self loadGroupsPanel];
        }
        else if ([panelId isEqualToString:UI_Panel_Key_Preference]) {
            [self loadPreferencePanel];
        }else if ([panelId isEqualToString:UI_Panel_Key_Chat]) {
            [self loadChatPanel];
        }
        else if ([panelId isEqualToString:UI_Panel_Key_NetworkTools]) {
            [self loadNetworkToolsPanel];
        }
        else if ([panelId isEqualToString:UI_Panel_Key_Map]) {
            [self loadMapPanel];
        }
        else if ([panelId isEqualToString:UI_Panel_Key_Mixing]) {
            [self loadMixingPanel];
        }
        else if ([panelId isEqualToString:UI_Panel_Key_Visual]) {
            [self loadVisualPanel];
        }

        else
        {
            [self createPanel:panelId withTitle:sender.identifier];
        }
    }
    else
    {
        [self hidePanel:panelId];
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
