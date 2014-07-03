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
#import "AMAppDelegate.h"
#import "AMMesher/AMAppObjects.h"
#import "AMMesher/AMMesherStateMachine.h"
#import "MZTimerLabel.h"


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
    AMUserGroupViewController *_userGroupViewController;
    AMBox *_containerView;
    AMETCDPreferenceViewController *preferenceViewController;
    AMSocialViewController * socialViewController;
    AMChatViewController *chatViewController;
    AMTestViewController *testViewController;
    AMMapViewController *mapViewController;
    AMMixingViewController *mixingViewController;
    AMVisualViewController  *visualViewController;
    MZTimerLabel *amTimerControl;
    
    float containerWidth;
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

-(void)awakeFromNib{

}

-(void)loadArchivedWindow:(NSView*)scrollView{
   
    [NSKeyedArchiver archiveRootObject:scrollView toFile:@"x5"];
}

-(void)showDefaultWindow
{
    [self initTimer];
//    [self.window setReleasedWhenClosed:NO];

//    if (![[NSFileManager defaultManager] fileExistsAtPath:@"x5"]) {
        [self createDefaultWindow];
//    }
//    else{
//        NSScrollView *scrollView=[NSKeyedUnarchiver unarchiveObjectWithFile:@"xujiantemp3"];
//        
//        [self.window setContentView:scrollView];
//    }
    
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
  //  _containerView.minSizeConstraint = _containerView.frame.size;
    _containerView.allowBecomeEmpty = YES;
    _containerView.gapBetweenItems = 50;
    CGFloat contentHeight = _containerView.frame.size.height;
     _containerView.prepareForAdding = ^(AMBoxItem *boxItem) {
         if ([boxItem isKindOfClass:[AMBox class]])
             return (AMBox *)nil;
         AMBox *newBox = [AMBox vbox];
         //newBox.minSizeConstraint = NSMakeSize(0, contentHeight);
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
   
    if ([openedPanels containsObject:UI_Panel_Key_User]) {
        [self loadUserPanel];
    }
    
       if ([openedPanels containsObject:UI_Panel_Key_Visual]) {
        [self loadVisualPanel];
    }
    if ([openedPanels containsObject:UI_Panel_Key_Mixing]) {
        [self loadMixingPanel];
    }
    
    if ([openedPanels containsObject:UI_Panel_Key_NetworkTools]) {
        
        [self loadNetworkToolsPanel];
    }
    if ([openedPanels containsObject:UI_Panel_Key_Preference]) {
        [self loadPreferencePanel];
    }
    
    if ([openedPanels containsObject:UI_Panel_Key_Chat]) {
        [self loadChatPanel];
    }
    
    if ([openedPanels containsObject:UI_Panel_Key_Groups]) {
        [self loadGroupsPanel];
    }
    if ([openedPanels containsObject:UI_Panel_Key_Social]) {
        [self loadFOAFPanel];
    }
    
    if ([openedPanels containsObject:UI_Panel_Key_MusicScore]) {
        [self loadMusicScorePanel];
    }
    
    if ([openedPanels containsObject:UI_Panel_Key_MainOutput]) {
        [self loadMainOutputPanel];
    }
    if ([openedPanels containsObject:UI_Panel_Key_Timer]) {
        [self loadTimerPanel];
    }
    if ([openedPanels containsObject:UI_Panel_Key_OSCMessage]) {
        [self loadOSCMessagePanel];

    }
    if ([openedPanels containsObject:UI_Panel_Key_Map]) {
        [self loadMapPanel];
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
//        panelViewController.view.frame = NSMakeRect(160+UI_defaultPanelWidth,
//                                                    self.window.frame.size.height-UI_topbarHeight-
//                                                    height+UI_pixelHeightAdjustment, width, height);
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    panelView.panelViewController = panelViewController;
    panelView.preferredSize = NSMakeSize(width, height);
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
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-21-[contentView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
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
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_Mixing withTitle:@"Mixing" width:UI_defaultPanelWidth*3.0 height:UI_defaultPanelHeight ];
    mixingViewController = [[AMMixingViewController alloc] initWithNibName:@"AMMixingViewController" bundle:nil];
    [self fillPanel:panelViewController.view content:mixingViewController.view];
}

-(void)loadVisualPanel{
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_Visual withTitle:@"Visualization" width:UI_defaultPanelWidth*3.0 height:UI_defaultPanelHeight ];
    visualViewController = [[AMVisualViewController alloc] initWithNibName:@"AMVisualViewController" bundle:nil];
    [visualViewController.view setAutoresizesSubviews:YES];
    [self fillPanel:panelViewController.view content:visualViewController.view];
}

-(void)loadOSCMessagePanel{
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_OSCMessage withTitle:@"OSC Message" width:UI_defaultPanelWidth height:UI_defaultPanelHeight ];
    NSViewController *viewController = [[AMVisualViewController alloc] initWithNibName:@"AMOSCMessageViewController" bundle:nil];
    [viewController.view setAutoresizesSubviews:YES];
    [self fillPanel:panelViewController.view content:viewController.view];
}

-(void)loadMainOutputPanel{
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_MainOutput withTitle:@"Main Output" width:UI_defaultPanelWidth*4 height:UI_defaultPanelHeight ];
    NSViewController *viewController = [[AMVisualViewController alloc] initWithNibName:@"AMMainOutputViewController" bundle:nil];
    [self fillPanel:panelViewController.view content:viewController.view];
}

-(void)loadTimerPanel{
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_Timer withTitle:@"Clock" width:UI_defaultPanelWidth height:UI_defaultPanelHeight ];
    NSViewController *viewController = [[AMVisualViewController alloc] initWithNibName:@"AMTimerViewController" bundle:nil];
    [self fillPanel:panelViewController.view content:viewController.view];
}

-(void)loadMusicScorePanel{
    AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_MusicScore withTitle:@"Music Score" width:UI_defaultPanelWidth height:UI_defaultPanelHeight ];
    NSViewController *viewController = [[AMVisualViewController alloc] initWithNibName:@"AMMusicScoreViewController" bundle:nil];
    [self fillPanel:panelViewController.view content:viewController.view];
}

-(void)loadFOAFPanel{
    
     AMPanelViewController* panelViewController=  [self createPanel:UI_Panel_Key_Social withTitle:@"Social" width:UI_defaultPanelWidth*2.0 height:UI_defaultPanelHeight ];

    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize panelSize = NSMakeSize(UI_defaultPanelWidth*2, UI_defaultPanelHeight);
    panelView.minSizeConstraint = panelSize;
//    panelView.maxSizeConstraint = panelSize;
    socialViewController = [[AMSocialViewController alloc] initWithNibName:@"AMSocialView" bundle:nil];
    socialViewController.view.frame = NSMakeRect(0, UI_panelContentPaddingBottom, UI_defaultPanelWidth*2, panelSize.height-UI_panelTitlebarHeight-UI_panelContentPaddingBottom);
    [panelViewController.view addSubview:socialViewController.view];
    [socialViewController.socialWebTab setFrameLoadDelegate:socialViewController];
    [socialViewController.socialWebTab setPolicyDelegate:socialViewController];
    [socialViewController.socialWebTab setUIDelegate:socialViewController];

    [socialViewController.socialWebTab setDrawsBackground:NO];
    containerWidth+=panelViewController.view.frame.size.width+UI_panelSpacing;
    [socialViewController loadPage];
}
-(void)initTimer{
    amTimerControl = [[MZTimerLabel alloc] initWithLabel:(NSTextField*)self.amTimer andTimerType:MZTimerLabelTypeStopWatch];
    [amTimerControl setStopWatchTime:0];
    amTimerControl.timeFormat=@"HH:mm:ss";
}

- (void)loadGroupsPanel {
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
    float panelWidth=UI_defaultPanelWidth*2;
    float panelHeight=UI_defaultPanelHeight;
    AMPanelViewController *panelViewController=[self createPanel:UI_Panel_Key_Preference withTitle:@"PREFERENCE"
                                                           width:panelWidth height:panelHeight];
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize panelSize = NSMakeSize(600.0f, UI_defaultPanelHeight);
    panelView.minSizeConstraint = panelSize;
//    panelView.maxSizeConstraint = panelSize;


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
    float panelHeight=720.0f;

    AMPanelViewController *panelViewController=[self createPanel:UI_Panel_Key_Chat withTitle:@"CHAT"
                                                           width:panelWidth height:panelHeight];
    AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    //NSSize maxPanelSize = NSMakeSize(600.0f, UI_defaultPanelHeight);
    panelView.minSizeConstraint = NSMakeSize(600.0f, 300.0f);
//    panelView.maxSizeConstraint = maxPanelSize;
    [panelViewController setTitle:@"CHAT"];
    chatViewController = [[AMChatViewController alloc] initWithNibName:@"AMChatView" bundle:nil];
    NSView *chatView = chatViewController.view;
    
    
    [self fillPanel:panelViewController.view content:chatViewController.view];
    
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
    //    NSSize maxSize = NSMakeSize(600.0f, 720);
    NSSize minSize = NSMakeSize(600.0f, 300);
    //    panelView.maxSizeConstraint = maxSize;
    panelView.minSizeConstraint = minSize;
    
    AMPingViewController *pingViewController = [[AMPingViewController alloc] initWithNibName:@"AMPingView" bundle:nil];
    panelViewController.subViewController = pingViewController;
    NSView *pingView = pingViewController.view;    
    pingView.frame = NSMakeRect(0, UI_panelTitlebarHeight, 600, 380);
    [panelView addSubview:pingView];
    
    [self fillPanel:panelViewController.view content:pingViewController.view];
    return panelViewController;
}

-(void)loadNetworkToolsPanel{
    [self createNetworkToolsPanelController:UI_Panel_Key_NetworkTools withTitle:@"NETWORK TOOLS"];
}

- (void)loadUserPanel {
    float panelHeight=300.0f;
    AMPanelViewController *panelViewController=[self createPanel:@"USER_PANEL" withTitle:@"USER" width:UI_defaultPanelWidth height:panelHeight];
        AMPanelView *panelView = (AMPanelView *)panelViewController.view;
    NSSize panelSize = NSMakeSize(UI_defaultPanelWidth, panelHeight);
    panelView.minSizeConstraint = panelSize;
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
        else if ([panelId isEqualToString:UI_Panel_Key_Social]) {
            [self loadFOAFPanel];
        }
        else if ([panelId isEqualToString:UI_Panel_Key_OSCMessage]) {
            [self loadOSCMessagePanel];
        }
        else if ([panelId isEqualToString:UI_Panel_Key_MusicScore]) {
            [self loadMusicScorePanel];
        }
        
       else if ([panelId isEqualToString:UI_Panel_Key_MainOutput]) {
            [self loadMainOutputPanel];
        }
        else if ([panelId isEqualToString:UI_Panel_Key_Timer]) {
            [self loadTimerPanel];
        }
        else
        {
            [self createPanel:panelId withTitle:sender.identifier];
        }
    }
    else
    {
        [self removePanel:panelId];
    }
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
