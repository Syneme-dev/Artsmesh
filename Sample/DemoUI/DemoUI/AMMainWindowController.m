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
#import "AMAppDelegate.h"
#import "AMMesher/AMAppObjects.h"
#import "AMMesher/AMMesherStateMachine.h"
#import "MZTimerLabel.h"
#import "AMGroupPanelViewController.h"


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
#define UI_Panel_Key_OSCMessage @"OSCMESSAGE_PANEL"

#define UI_Panel_Key_Social @"SOCIAL_PANEL"


#define UI_Panel_Key_Timer @"TIMER_PANEL"

#define UI_Panel_Key_MusicScore @"MUSICSCORE_PANEL"

#define UI_Panel_Key_MainOutput @"MAINOUTPUT_PANEL"




@interface AMMainWindowController ()

@end

@implementation AMMainWindowController
{
    AMGroupPanelViewController *_userGroupViewController;
    AMBox *_containerView;
    AMETCDPreferenceViewController *preferenceViewController;
    AMSocialViewController * socialViewController;
    AMChatViewController *chatViewController;
    AMTestViewController *testViewController;
    AMMapViewController *mapViewController;
    AMMixingViewController *mixingViewController;
    AMUserViewController *userViewController;
    AMVisualViewController  *visualViewController;
    MZTimerLabel *amTimerControl;
    
    float containerWidth;
}

- (NSView *)containerView
{
    return _containerView;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        _panelControllers=[[NSMutableDictionary alloc] init];
        
        AMAppDelegate *appDelegate = [NSApp delegate];
        self.window.restorable = YES;
        self.window.restorationClass = [appDelegate class];
        self.window.identifier = @"mainWindow";
    }
    return self;
}

- (void)windowDidResize:(NSNotification *)notification
{
    CGFloat height = 0;
    for (AMBox *box in _containerView.subviews) {
        height = MAX(height, [box minContentHeight] + box.paddingTop + box.paddingBottom);
    }
    height += _containerView.paddingTop + _containerView.paddingBottom;
    NSScrollView *scrollView = [[self.window.contentView subviews] objectAtIndex:0];
    height = MAX(height, scrollView.frame.size.height);
    _containerView.frame = NSMakeRect(0, 0, 0, height);
    for (AMBox *box in _containerView.subviews) {
        [box setFrameSize:NSMakeSize(box.frame.size.width, height)];
        [box doBoxLayout];
    }
    [_containerView doBoxLayout];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (IBAction)mesh:(id)sender {
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    if (machine == nil) {
        return;
    }
    
    AMMesher* mesher = [AMMesher sharedAMMesher];
    
    if (machine.mesherState == kMesherStarted) {
        [mesher goOnline];
        self.meshBtn.state = 0;
    }else if(machine.mesherState == kMesherMeshed){
        [mesher goOffline];
        self.meshBtn.state = 2;
    }else{
        AMUser* mySelf = [[AMAppObjects appObjects] objectForKey:AMMyselfKey];
        if (mySelf.isOnline == YES) {
            self.meshBtn.state = 0;
        }else{
            self.meshBtn.state = 2;
        }
        return;
    }

}

-(void)loadVersion{
    NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    [self.versionLabel setStringValue:[NSString stringWithFormat:@"%@.%@",shortVersion,buildVersion]];
}



-(void)showDefaultWindow
{
    [self initTimer];
    [self createDefaultWindow];
    [self loadTestPanel];
    
}

- (void)copyPanel:(NSButton *)sender
{
    static int numberOfNetworkToolsPanel = 0;
    
    AMPanelView *panelView = (AMPanelView *)sender.superview.superview;
    AMPanelViewController *controller = (AMPanelViewController *)panelView.panelViewController;
    
    if (controller.panelType == AMNetworkToolsPanelType) {
        NSString *newId = [NSString stringWithFormat:@"%@_%d", controller.panelId,
                       ++numberOfNetworkToolsPanel];
        NSString *newTitle = [NSString stringWithFormat:@"NETWORK TOOLS - %d", numberOfNetworkToolsPanel];
        AMPanelViewController *newController =
            [self createNetworkToolsPanelController:newId withTitle:newTitle];
        AMPanelView *newPanel = (AMPanelView *)newController.view;
        [newController.view removeFromSuperview];
        [_containerView addSubview:newPanel positioned:NSWindowAbove relativeTo:panelView.hostingBox];
        [newPanel scrollRectToVisible:newPanel.frame];
    }
}

- (void)createDefaultWindow {
     NSScreen *mainScreen = [NSScreen mainScreen];
    [self.window setFrame:NSMakeRect(10, 40 , mainScreen.frame.size.width-80,mainScreen.frame.size.height-80) display:YES];
    NSSize windowSize = [self.window.contentView frame].size;
    NSScrollView *scrollView = [[self.window.contentView subviews] objectAtIndex:0];
    scrollView.frame = NSMakeRect(UI_leftSidebarWidth+10,
                                  0,
                                  windowSize.width - UI_leftSidebarWidth,
                                  windowSize.height - UI_topbarHeight-20);
    _containerView = [AMBox hbox];
    _containerView.frame = scrollView.bounds;
    _containerView.paddingLeft = 40;
    _containerView.paddingRight = 50;
    _containerView.allowBecomeEmpty = YES;
    _containerView.gapBetweenItems = 50;
    CGFloat contentHeight = _containerView.frame.size.height;
     _containerView.prepareForAdding = ^(AMBoxItem *boxItem) {
         if ([boxItem isKindOfClass:[AMBox class]])
             return (AMBox *)nil;
         AMBox *newBox = [AMBox vbox];
         newBox.paddingTop = 20;
         newBox.paddingBottom = 40;
         newBox.paddingLeft = 6;
         newBox.paddingRight = 0;
         newBox.gapBetweenItems = 40;
         CGFloat width = boxItem.preferredSize.width + newBox.paddingLeft +
                            newBox.paddingRight;
         [newBox setFrameSize:NSMakeSize(width, contentHeight)];
         [newBox addSubview:boxItem];
         return newBox;
     };
    [scrollView setDocumentView:_containerView];
    [self loadVersion];
    NSMutableArray *openedPanels=(NSMutableArray*)[[AMPreferenceManager instance] objectForKey:UserData_Key_OpenedPanel];
    for (NSString* openedPanelId in openedPanels) {
        if([openedPanelId rangeOfString:@"_PANEL"].location!=NSNotFound)
        {
            [self createPanelWithType:openedPanelId withId:openedPanelId];
            NSString *sideItemId=[openedPanelId stringByReplacingOccurrencesOfString:@"_PANEL" withString:@""];
            [self setSideBarItemStatus:sideItemId withStatus:YES ];
        }
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
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    panelView.panelViewController = panelViewController;
    panelView.preferredSize = NSMakeSize(width, height);
    panelView.initialSize = panelView.preferredSize;
        [panelViewController setTitle:title];
    
    NSView *firstPanel=nil;
    if(_containerView.subviews.count>0)
    {
        firstPanel=_containerView.subviews[0];
    }
        [_containerView addSubview:panelViewController.view  positioned:NSWindowAbove relativeTo:firstPanel];
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

-(void)removePanel:(NSString *)panelName{
    AMPanelViewController* pannelViewController=self.panelControllers[panelName];
    [pannelViewController closePanel:nil];
  
}


-(void)fillPanel:(NSView*) panelView content:(NSView*)contentView{
    NSSize panelSize = panelView.frame.size;
    contentView.frame = NSMakeRect(0, UI_panelContentPaddingBottom, panelSize.width, panelSize.height-UI_panelTitlebarHeight-UI_panelContentPaddingBottom);
    [panelView addSubview:contentView];
   // [contentView setNeedsDisplay:YES];
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
    [panelView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [panelView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-21-[contentView]-21-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
}

-(AMPanelViewController*) loadTestPanel{
    AMPanelViewController* panelViewController=  [self createPanel:@"TEST_PANEL" withTitle:@"test"];
        testViewController = [[AMTestViewController alloc] initWithNibName:@"AMTestView" bundle:nil];
        [self fillPanel:panelViewController.view content:testViewController.view];
    return panelViewController;
    }

-(AMPanelViewController*) loadMapPanel{
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_Map withTitle:@"Map" width:UI_defaultPanelWidth*4.0 height:UI_defaultPanelHeight ];
    mapViewController = [[AMMapViewController alloc] initWithNibName:@"AMMapViewController" bundle:nil];
    [self fillPanel:panelViewController.view content:mapViewController.view];
    return panelViewController;
}

-(AMPanelViewController*) loadMixingPanel{
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_Mixing withTitle:@"Mixing" width:UI_defaultPanelWidth*3.0 height:UI_defaultPanelHeight ];
    mixingViewController = [[AMMixingViewController alloc] initWithNibName:@"AMMixingViewController" bundle:nil];
    [self fillPanel:panelViewController.view content:mixingViewController.view];
    return panelViewController;
}

-(AMPanelViewController*) loadVisualPanel{
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_Visual withTitle:@"Visualization" width:UI_defaultPanelWidth*3.0 height:UI_defaultPanelHeight ];
    visualViewController = [[AMVisualViewController alloc] initWithNibName:@"AMVisualViewController" bundle:nil];
    [visualViewController.view setAutoresizesSubviews:YES];
    [self fillPanel:panelViewController.view content:visualViewController.view];
    return panelViewController;
}

-(AMPanelViewController*)loadOSCMessagePanel{
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_OSCMessage withTitle:@"OSC Message" width:UI_defaultPanelWidth height:UI_defaultPanelHeight ];
    NSViewController *viewController = [[AMVisualViewController alloc] initWithNibName:@"AMOSCMessageViewController" bundle:nil];
    [viewController.view setAutoresizesSubviews:YES];
    [self fillPanel:panelViewController.view content:viewController.view];
    return panelViewController;
}

-(AMPanelViewController*)loadMainOutputPanel{
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_MainOutput withTitle:@"Main Output" width:UI_defaultPanelWidth*4 height:UI_defaultPanelHeight ];
    NSViewController *viewController = [[AMVisualViewController alloc] initWithNibName:@"AMMainOutputViewController" bundle:nil];
    [self fillPanel:panelViewController.view content:viewController.view];
    return panelViewController;
}

-(AMPanelViewController*)loadTimerPanel{
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_Timer withTitle:@"Clock" width:UI_defaultPanelWidth height:UI_defaultPanelHeight ];
    NSViewController *viewController = [[AMVisualViewController alloc] initWithNibName:@"AMTimerViewController" bundle:nil];
    [self fillPanel:panelViewController.view content:viewController.view];
    return panelViewController;
}

-(AMPanelViewController*)loadMusicScorePanel{
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_MusicScore withTitle:@"Music Score" width:UI_defaultPanelWidth height:UI_defaultPanelHeight ];
    NSViewController *viewController = [[AMVisualViewController alloc] initWithNibName:@"AMMusicScoreViewController" bundle:nil];
    [self fillPanel:panelViewController.view content:viewController.view];
    return panelViewController;
}

-(AMPanelViewController*)loadFOAFPanel{
    
     AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_Social withTitle:@"Social" width:UI_defaultPanelWidth*2.0 height:UI_defaultPanelHeight ];
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize panelSize = NSMakeSize(UI_defaultPanelWidth*2, UI_defaultPanelHeight);
    panelView.minSizeConstraint = panelSize;
    socialViewController = [[AMSocialViewController alloc] initWithNibName:@"AMSocialView" bundle:nil];
    [self fillPanel:panelViewController.view content:socialViewController.view];
    [socialViewController.socialWebTab setDrawsBackground:NO];
    containerWidth+=panelViewController.view.frame.size.width+UI_panelSpacing;
    [socialViewController loadPage];
    return panelViewController;
}
-(void)initTimer{
    amTimerControl = [[MZTimerLabel alloc] initWithLabel:(NSTextField*)self.amTimer andTimerType:MZTimerLabelTypeStopWatch];
    [amTimerControl setStopWatchTime:0];
    amTimerControl.timeFormat=@"HH:mm:ss";
}

- (AMPanelViewController*)loadGroupsPanel {
    float panelWidth=UI_defaultPanelWidth;
    float panelHeight=340.0f;
    AMPanelViewController *panelViewController=[self createPanel:UI_Panel_Key_Groups
                                                       withTitle:@"GROUPS"
                                                           width:panelWidth
                                                          height:panelHeight];
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    //TODO:create a group panel below the user panel by default.
    //TODO:sample code like below.
    
//    NSMutableArray *openedPanels=[[[AMPreferenceManager instance] objectForKey:UserData_Key_OpenedPanel] mutableCopy];
//    if([openedPanels containsObject:UI_Panel_Key_User])
//    {
//        
//        AMPanelViewController *userPanelViewController=self.panelControllers[UI_Panel_Key_User];
//        NSRect userViewFrame=userPanelViewController.view.frame;
//        [panelView setFrameOrigin:NSMakePoint(userViewFrame.origin.x, userViewFrame.origin.y+100.0+userViewFrame.size.height)];
//        [panelView setNeedsDisplay:YES];
//    }

  
    NSSize panelSize = NSMakeSize(300.0f, 220.0f);
    panelView.minSizeConstraint = panelSize;
    _userGroupViewController = [[AMGroupPanelViewController alloc] initWithNibName:@"AMUserGroupView" bundle:nil];
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
    
    
    return panelViewController;


}

- (AMPanelViewController*)loadPreferencePanel {
    float panelWidth=UI_defaultPanelWidth*2;
    float panelHeight=UI_defaultPanelHeight;
    AMPanelViewController *panelViewController=[self createPanel:UI_Panel_Key_Preference withTitle:@"PREFERENCE"
                                                           width:panelWidth height:panelHeight];
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize panelSize = NSMakeSize(600.0f, UI_defaultPanelHeight);
    panelView.minSizeConstraint = panelSize;
    preferenceViewController = [[AMETCDPreferenceViewController alloc] initWithNibName:@"AMETCDPreferenceView" bundle:nil];
    NSView *preferenceView = preferenceViewController.view;
    [self fillPanel:panelViewController.view content:preferenceViewController.view];
    [preferenceViewController loadSystemInfo];
    [preferenceViewController customPrefrence];
    [preferenceView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    NSDictionary *views = NSDictionaryOfVariableBindings(preferenceView);
    //TODO:useless code ,please help check and remove it.
//    [panelView addConstraints:        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[preferenceView]|"
//                                                                              options:0
//                                                                              metrics:nil
//                                                                                views:views]];
//    
//    [panelView addConstraints:
//     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-21-[preferenceView]|"
//                                             options:0
//                                             metrics:nil
//                                               views:views]];
return panelViewController;
    

}

- (AMPanelViewController*)loadChatPanel {
    float panelWidth=600.0f;
    float panelHeight=720.0f;

    AMPanelViewController *panelViewController=[self createPanel:UI_Panel_Key_Chat withTitle:@"CHAT"
                                                           width:panelWidth height:panelHeight];
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    panelView.minSizeConstraint = NSMakeSize(600.0f, 300.0f);
    chatViewController = [[AMChatViewController alloc] initWithNibName:@"AMChatView" bundle:nil];
    [self fillPanel:panelViewController.view content:chatViewController.view];
    return panelViewController;
    
    /*
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
     */
}

- (AMPanelViewController *)createNetworkToolsPanelController:(NSString *)ident
                                                   withTitle:(NSString *)title
{
    float panelWidth=600.0f;
    float panelHeight=720.0f;
    AMPanelViewController *panelViewController=[self createPanel:ident withTitle:title width:panelWidth height:panelHeight];
    panelViewController.panelType = AMNetworkToolsPanelType;
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize minSize = NSMakeSize(600.0f, 300);
    panelView.minSizeConstraint = minSize;
    AMPingViewController *pingViewController = [[AMPingViewController alloc] initWithNibName:@"AMPingView" bundle:nil];
    panelViewController.subViewController = pingViewController;
    NSView *pingView = pingViewController.view;    
    pingView.frame = NSMakeRect(0, UI_panelTitlebarHeight, 600, 380);
    [panelView addSubview:pingView];
    [self fillPanel:panelViewController.view content:pingViewController.view];
    return panelViewController;
}

-(AMPanelViewController*)loadNetworkToolsPanel{
    return [self createNetworkToolsPanelController:UI_Panel_Key_NetworkTools withTitle:@"NETWORK TOOLS"];
}

- (AMPanelViewController*) loadProfilePanel:(NSString*)panelId {
    float panelHeight = 300.0f;
    AMPanelViewController *panelViewController=[self createPanel:panelId withTitle:@"PROFILE" width:UI_defaultPanelWidth height:panelHeight];
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize minSize = NSMakeSize(UI_defaultPanelWidth, UI_defaultPanelWidth);
    panelView.minSizeConstraint = minSize;
    
    userViewController = [[AMUserViewController alloc] initWithNibName:@"AMUserView" bundle:nil];
    NSView* profileView = userViewController.view;
    [panelView addSubview:profileView];
    
    [self fillPanel:panelViewController.view content:userViewController.view];
    panelViewController.tabPanelViewController=userViewController;

    return panelViewController;
}

- (IBAction)onSidebarItemClick:(NSButton *)sender {
    NSString *panelId=
    [[NSString stringWithFormat:@"%@_PANEL",sender.identifier ] uppercaseString];
    if(sender.state==NSOnState)
    {
        [self createPanelWithType:panelId withId:panelId];
    }
    else
    {
        [self removePanel:panelId];
    }
}

-(AMPanelViewController *)createPanelWithType:(NSString*)panelType withId:(NSString*)panelId{
    AMPanelViewController *panelViewController;
    if ([panelType isEqualToString:UI_Panel_Key_User]) {
        panelViewController=[self loadProfilePanel:panelId];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Groups]) {
        panelViewController= [self loadGroupsPanel];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Preference]) {
        panelViewController= [self loadPreferencePanel];
    }else if ([panelType isEqualToString:UI_Panel_Key_Chat]) {
        panelViewController=  [self loadChatPanel];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_NetworkTools]) {
        panelViewController=  [self loadNetworkToolsPanel];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Map]) {
        panelViewController=  [self loadMapPanel];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Mixing]) {
        panelViewController=  [self loadMixingPanel];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Visual]) {
        panelViewController=   [self loadVisualPanel];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Social]) {
        panelViewController=  [self loadFOAFPanel];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_OSCMessage]) {
        panelViewController=  [self loadOSCMessagePanel];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_MusicScore]) {
        panelViewController= [self loadMusicScorePanel];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_MainOutput]) {
        panelViewController=  [self loadMainOutputPanel];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Timer]) {
        panelViewController=  [self loadTimerPanel];
    }
    else
    {
        //TODO:check whether need to load the panel having different panelType.
       // panelViewController=   [self createPanel:panelType withTitle:panelId];
    }
    return panelViewController;

}

-(void)createTabPanelWithType:(NSString*)panelType withTitle:(NSString*)title  withTabId:(NSString*)tabId withTabIndex:(NSInteger)tabIndex from:(AMPanelViewController*)fromController{
    
    NSString *panelId=[NSString stringWithFormat:@"%@_%@",panelType,tabId];
    AMPanelViewController *panelViewController=[self createPanelWithType:panelType withId:panelId];
    
    if(panelViewController.tabPanelViewController!=nil)
    {
        [panelViewController showAsTabPanel:title withTabIndex:tabIndex];
    }
    panelViewController.movedFromController=fromController;

}



- (IBAction)onTimerControlItemClick:(NSButton *)sender {

    if(sender.state==NSOnState)
    {
        [amTimerControl start];
    }
    else
    {
        [amTimerControl pause];
        [amTimerControl reset];
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

-(void)encodeRestorableStateWithCoder{
}
@end
