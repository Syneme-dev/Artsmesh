//
//  AMMainWindowController.m
//  DemoUI
//
//  Created by xujian on 4/17/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//


#import "AMMainWindowController.h"
#import <AMPluginLoader/AMPluginAppDelegateProtocol.h>
#import "AMAppDelegate.h"
#import <AMPreferenceManager/AMPreferenceManager.h>
#import "AMETCDPreferenceViewController.h"
#import "AMUserViewController.h"
#import "AMSocialViewController.h"
#import <UIFramework/BlueBackgroundView.h>
#import <AMCoreData/AMCoreData.h>
#import "AMChatViewController.h"
#import "AMNetworkToolsViewController.h"
#import "UIFramework/AMBox.h"
#import "UIFramework/AMPanelView.h"
#import "AMTestViewController.h"
#import "AMMixingViewController.h"
#import "AMVisualViewController.h"
#import "AMMapViewController.h"
#import "AMGroupPanelViewController.h"
#import "AMCoreData/AMCoreData.h"
#import "AMMesher/AMMesher.h"
#import "AMPanelControlBarViewController.h"
#import "AMTimer/AMTimer.h"
#import "AMTimerViewController.h"
#import "AMMusicScoreViewController.h"
#import "AMOSCMessageViewController.h"
#import "AMGPlusViewController.h"
#import "AMManualViewController.h"
#import "AMAudio/AMAudio.h"
#import "AMOSCGroups/AMOSCGroups.h"
#import "AMVideo.h"
#import "UIFramework/AMFoundryFontView.h"


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
#define UI_Panel_Key_Visual @"ROUTING_PANEL"
#define UI_Panel_Key_OSCMessage @"OSCMESSAGE_PANEL"

#define UI_Panel_Key_Social @"SOCIAL_PANEL"
#define UI_Panel_Key_Timer @"TIMER_PANEL"
#define UI_Panel_Key_MusicScore @"MUSICSCORE_PANEL"
#define UI_Panel_Key_MainOutput @"MAINOUTPUT_PANEL"

#define UI_Panel_Key_GPlus @"GPLUS_PANEL"
#define UI_Panel_Key_Manual @"MANUAL_PANEL"

@interface AMMainWindowController ()

@end

@implementation AMMainWindowController {
    AMBox *_containerView;
    //MZTimerLabel *amTimerControl;
    AMPanelControlBarViewController *controlBarController;
    Boolean isWindowLoading;

    float containerWidth;
    
    NSTimer *_jackCpuTimer;
}

- (NSView *)containerView {
    return _containerView;
}

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        _panelControllers = [[NSMutableDictionary alloc] init];

        AMAppDelegate *appDelegate = [NSApp delegate];
        self.window.restorable = YES;
        self.window.restorationClass = [appDelegate class];
        self.window.identifier = @"mainWindow";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myStatucChanged) name:AM_MYSELF_CHANGED_REMOTE object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jackStarted:) name:AM_JACK_STARTED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jackStopped:) name:AM_JACK_STOPPED_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oscStarted:) name:AM_OSC_SRV_STARTED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oscStopped:) name:AM_OSC_SRV_STOPPED_NOTIFICATION object:nil];
    
        [[AMTimer shareInstance] addObserver:self
                                  forKeyPath:@"state"
                                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                     context:nil];
        
    }
    return self;
}

- (void)windowWillClose:(NSNotification *)notification {
    [[AMTimer shareInstance] removeObserver:self forKeyPath:@"state"];
}


- (void)windowDidResize:(NSNotification *)notification {
    CGFloat height = [self calculateContainerHeight];
    [self resizeContainerHeightTo:height];
}

- (CGFloat)calculateContainerHeight {
    CGFloat height = 0;
    for (AMBox *box in _containerView.subviews) {
        height = MAX(height, [box minContentHeight] + box.paddingTop + box.paddingBottom);
    }
    height += _containerView.paddingTop + _containerView.paddingBottom;
    NSScrollView *scrollView = [[self.window.contentView subviews] objectAtIndex:0];
    height = MAX(height, scrollView.frame.size.height);
    return height;
}

- (void)resizeContainerHeightTo:(CGFloat)height {
    [_containerView setFrameSize:NSMakeSize(_containerView.frame.size.width, height)];
    for (AMBox *box in _containerView.subviews) {
        [box setFrameSize:NSMakeSize(box.frame.size.width, height)];
    }
    for (AMBox *box in _containerView.subviews) {
        [box doBoxLayout];
    }
}

- (void)myStatucChanged {
    if ([[AMMesher sharedAMMesher] mesherState] == kMesherMeshed){
        self.meshBtn.state = 0;
    }else{
        self.meshBtn.state = 2;
    }
}


- (IBAction)mesh:(id)sender {

    AMMesher* mesher = [AMMesher sharedAMMesher];
    if ([mesher mesherState] == kMesherUnmeshed){
        [mesher goOnline];
    }else{
        [mesher goOffline];
    }
}

- (void)loadVersion {
    NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
//    NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    [self.versionLabel setStringValue:[NSString stringWithFormat:@"%@", shortVersion]];
}


- (void)showDefaultWindow {
    isWindowLoading = YES;
    [self initTimer];
    [self createDefaultWindow];
//    [self loadTestPanel]; //Note:uncomment this code to show test panel.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isTopBar = [defaults boolForKey:Preference_Key_General_TopControlBar];

    [self initControlBar:isTopBar];
    [self createDefaultPanelAndloadControlBarItemStatus];
    isWindowLoading = NO;
}

- (void)initControlBar:(BOOL)isTop {
    if (controlBarController) {
        [controlBarController.view removeFromSuperview];
    }
    NSSize windowSize = [self.window.contentView frame].size;
    if (isTop) {
        NSPoint point = NSMakePoint(450, windowSize.height - 60);
        controlBarController = [[AMPanelControlBarViewController alloc] initWithNibName:@"PanelControlBarView" bundle:nil];
        [controlBarController.view setFrameOrigin:point];
        [self.window.contentView addSubview:controlBarController.view];
    }
    else {

        controlBarController = [[AMPanelControlBarViewController alloc] initWithNibName:@"VerticalControlBarView" bundle:nil];
        NSPoint point = NSMakePoint(0, windowSize.height - 60 - 20 - controlBarController.view.frame.size.height);
        [controlBarController.view setFrameOrigin:point];
        [self.window.contentView addSubview:controlBarController.view];

    }
    NSView *contentView = [self.window contentView];
    NSScrollView *scrollView = [[self.window.contentView subviews] objectAtIndex:0];
    NSView *customView = scrollView;
    [customView setTranslatesAutoresizingMaskIntoConstraints:NO];

    //    [contentView addSubview:customView];

    NSDictionary *views = NSDictionaryOfVariableBindings(customView);
    NSArray *constraints50 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[customView]-10-|" options:0
                                                                     metrics:nil
                                                                       views:views];
    NSArray *constraints10 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[customView]-10-|" options:0
                                                                     metrics:nil
                                                                       views:views];
    NSLayoutConstraint *itemFor10 = constraints10[0];
    [itemFor10 setIdentifier:@"leftSideBarConstrainsId10"];
    NSLayoutConstraint *itemFor50 = constraints50[0];
    [itemFor50 setIdentifier:@"leftSideBarConstrainsId50"];


    NSArray *constrains = [contentView constraints];
    for (NSLayoutConstraint *item in constrains) {
        if ([item.identifier isEqualToString:@"leftSideBarConstrainsId10"]
                || [item.identifier isEqualToString:@"leftSideBarConstrainsId50"]) {
            [contentView removeConstraint:item];
        }
    }
    [scrollView removeConstraints:scrollView.constraints];
    if (!isTop) {
        [contentView addConstraints:constraints50];
    }
    else {
        [contentView addConstraints:constraints10];

    }
}

- (void)createDefaultPanelAndloadControlBarItemStatus {
    NSMutableArray *openedPanels = (NSMutableArray *) [[AMPreferenceManager standardUserDefaults] objectForKey:UserData_Key_OpenedPanel];
    for (NSString *openedPanelId in openedPanels) {
        if ([openedPanelId rangeOfString:@"_PANEL"].location != NSNotFound) {
            [self createPanelWithType:openedPanelId withId:openedPanelId];
            NSString *sideItemId = [openedPanelId stringByReplacingOccurrencesOfString:@"_PANEL" withString:@""];
            [self setSideBarItemStatus:sideItemId withStatus:YES ];
        }
    }
}

- (void)loadControlBarItemStatus {
    NSMutableArray *openedPanels = (NSMutableArray *) [[AMPreferenceManager standardUserDefaults] objectForKey:UserData_Key_OpenedPanel];
    for (NSString *openedPanelId in openedPanels) {
        if ([openedPanelId rangeOfString:@"_PANEL"].location != NSNotFound) {
            NSString *sideItemId = [openedPanelId stringByReplacingOccurrencesOfString:@"_PANEL" withString:@""];
            [self setSideBarItemStatus:sideItemId withStatus:YES ];
        }
    }
}

- (void)copyPanel:(NSButton *)sender {
    static int numberOfNetworkToolsPanel = 0;

    AMPanelView *panelView = (AMPanelView *) sender.superview.superview;
    AMPanelViewController *controller = (AMPanelViewController *) panelView.panelViewController;

    if (controller.panelType == AMNetworkToolsPanelType) {
        NSString *newId = [NSString stringWithFormat:@"%@_%d", controller.panelId,
                                                     ++numberOfNetworkToolsPanel];
        NSString *newTitle = [NSString stringWithFormat:@"NETWORK TOOLS - %d", numberOfNetworkToolsPanel];
        AMPanelViewController *newController =
                [self createNetworkToolsPanelController:newId withTitle:newTitle relatedView:nil];
        AMPanelView *newPanel = (AMPanelView *) newController.view;
        [newController.view removeFromSuperview];
        [_containerView addSubview:newPanel positioned:NSWindowAbove relativeTo:panelView.hostingBox];
        [newPanel scrollRectToVisible:newPanel.frame];
    }
}

- (void)createDefaultWindow {
    NSScreen *mainScreen = [NSScreen mainScreen];
    [self.window setFrame:NSMakeRect(10, 40, mainScreen.frame.size.width - 80, mainScreen.frame.size.height - 80) display:YES];
    NSSize windowSize = [self.window.contentView frame].size;
    NSScrollView *scrollView = [[self.window.contentView subviews] objectAtIndex:0];

    scrollView.frame = NSMakeRect(UI_leftSidebarWidth+ 10,
            0,
            windowSize.width - UI_leftSidebarWidth,
            windowSize.height - UI_topbarHeight- 20);

    [scrollView setHorizontalLineScroll:100];
    [scrollView  setNeedsDisplay:YES];
   

    _containerView = [AMBox hbox];
    _containerView.frame = scrollView.bounds;
    _containerView.paddingLeft = 40;
    _containerView.paddingRight = 50;
    _containerView.allowBecomeEmpty = YES;
    _containerView.gapBetweenItems = 50;
    id __weak weakSelf = self;
    _containerView.prepareForAdding = ^(AMBoxItem *boxItem) {
        if ([boxItem isKindOfClass:[AMBox class]])
            return (AMBox *) nil;
        AMBox *newBox = [AMBox vbox];
        newBox.paddingTop = 20;
        newBox.paddingBottom = 40;
        newBox.paddingLeft = 6;
        newBox.paddingRight = 0;
        newBox.gapBetweenItems = 40;
        CGFloat width = boxItem.preferredSize.width + newBox.paddingLeft +
                newBox.paddingRight;
        CGFloat height = boxItem.minSizeConstraint.height + newBox.paddingTop + newBox.paddingBottom;
        id strongSelf = weakSelf;
        CGFloat containerHeight = [strongSelf calculateContainerHeight];
        if (containerHeight < height)
            [strongSelf resizeContainerHeightTo:height];
        else
            height = containerHeight;
        [newBox setFrameSize:NSMakeSize(width, height)];
        [newBox addSubview:boxItem];
        return newBox;
    };
    [scrollView setDocumentView:_containerView];
    [self loadVersion];

    [self windowDidResize:nil];  // temporary resolution
}


- (AMPanelViewController *)createPanel:(NSString *)identifier withTitle:(NSString *)title {
    AMPanelViewController *viewController =
            [self createPanel:identifier withTitle:title width:UI_defaultPanelWidth height:UI_defaultPanelHeight relatedView:nil];
    return viewController;

}
- (AMPanelViewController *)createPanel:(NSString *)identifier withTitle:(NSString *)title width:(float)width height:(float)height {
    return [self createPanel:identifier withTitle:title width:width height:height relatedView:nil];
}

- (AMPanelViewController *)createPanel:(NSString *)identifier withTitle:(NSString *)title width:(float)width height:(float)height relatedView:(NSView*)relatedView {
    AMPanelViewController *panelViewController =
            [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    panelViewController.panelId = identifier;
    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
    panelView.panelViewController = panelViewController;
    panelView.preferredSize = NSMakeSize(width, height);
    panelView.initialSize = panelView.preferredSize;
    [panelViewController setTitle:title];

    NSView *firstPanel = nil;
    NSScrollView *scrollView = [[self.window.contentView subviews] objectAtIndex:0];
    CGFloat x = [[scrollView contentView] documentVisibleRect].origin.x;
    NSClipView *documentView = scrollView.contentView.documentView;
    CGFloat diffX = documentView.frame.size.width;
    if (_containerView.subviews.count > 0 && !isWindowLoading) {
        if(relatedView){
            firstPanel=relatedView.superview;
            [_containerView addSubview:panelViewController.view positioned:NSWindowAbove
                            relativeTo:firstPanel];
        }
        else{
        for (NSString *openedPanelId in self.panelControllers.allKeys) {
            AMAppDelegate *appDelegate = [NSApp delegate];
            AMPanelViewController *firstPanelViewController = appDelegate.mainWindowController.panelControllers[openedPanelId];
            AMBoxItem *boxItem = (AMBoxItem *) firstPanelViewController.view;
            AMBox *box = [boxItem hostingBox];
                if (box.frame.origin.x > x && box.frame.origin.x - x - diffX < 0) {
                diffX = box.frame.origin.x - x;
                firstPanel = firstPanelViewController.view.superview;
                }
            }
             [_containerView addSubview:panelViewController.view positioned:NSWindowBelow relativeTo:firstPanel];
        }
       
    }
    else {
        [_containerView addSubview:panelViewController.view];
    }
    [self.panelControllers setObject:panelViewController forKey:identifier];
    NSMutableArray *openedPanels = [[[AMPreferenceManager standardUserDefaults] objectForKey:UserData_Key_OpenedPanel] mutableCopy];
    if (![openedPanels containsObject:identifier]) {
        [openedPanels addObject:identifier];
    }

    [[AMPreferenceManager standardUserDefaults] setObject:openedPanels forKey:UserData_Key_OpenedPanel];
    return panelViewController;
}

- (void)removePanel:(NSString *)panelName {
    AMPanelViewController *panelViewController = self.panelControllers[panelName];
    [panelViewController closePanel:nil];

}


- (void)fillPanel:(AMPanelViewController *)panelController content:(NSViewController *)contentController {
    NSView *panelView = panelController.view;
    NSView *contentView = contentController.view;
    panelController.contentPanelViewController = contentController;
    NSSize panelSize = panelView.frame.size;
    contentView.frame = NSMakeRect(0, UI_panelContentPaddingBottom, panelSize.width, panelSize.height - UI_panelTitlebarHeight- UI_panelContentPaddingBottom);
    [panelView addSubview:contentView];
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
    if ([contentController isKindOfClass:[AMTabPanelViewController class]]) {
        AMTabPanelViewController *tabPanelController = (AMTabPanelViewController *) contentController;
        panelController.tabPanelViewController = tabPanelController;

    }
}

- (AMPanelViewController *)loadTestPanel {
    AMPanelViewController *panelViewController = [self createPanel:@"TEST_PANEL" withTitle:@"test"];
    AMTestViewController *testViewController = [[AMTestViewController alloc] initWithNibName:@"AMTestView" bundle:nil];
    [self fillPanel:panelViewController content:testViewController];
    return panelViewController;
}

- (AMPanelViewController *)loadMapPanel:(NSString *)panelId relatedView:(NSView*)view{
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"MAP" width:UI_defaultPanelWidth* 4.0 height:UI_defaultPanelHeight relatedView:view];
    AMMapViewController *mapViewController = [[AMMapViewController alloc] initWithNibName:@"AMMapViewController" bundle:nil];
    [self fillPanel:panelViewController content:mapViewController];
    return panelViewController;
}

- (AMPanelViewController *)loadMixingPanel:(NSString *)panelId  relatedView:(NSView*)view{
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"MIXING" width:UI_defaultPanelWidth* 3.0 height:UI_defaultPanelHeight relatedView:view ];
    AMMixingViewController *mixingViewController = [[AMMixingViewController alloc] initWithNibName:@"AMMixingViewController" bundle:nil];
    [self fillPanel:panelViewController content:mixingViewController];
    return panelViewController;
}

- (AMPanelViewController *)loadRoutingPanel:(NSString *)panelId relatedView:(NSView*)view {
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"ROUTING" width:UI_defaultPanelWidth* 3.0 height:UI_defaultPanelHeight relatedView:view ];
    AMVisualViewController *visualViewController = [[AMVisualViewController alloc] initWithNibName:@"AMVisualViewController" bundle:nil];
    [self fillPanel:panelViewController content:visualViewController];
    return panelViewController;
}

- (AMPanelViewController *)loadOSCMessagePanel:(NSString *)panelId relatedView:(NSView*)view {
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"OSC MESSAGE" width:UI_defaultPanelWidth*2 height:UI_defaultPanelHeight relatedView:view];
    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
    panelView.minSizeConstraint = panelView.frame.size;
    NSViewController *viewController = [[AMOSCMessageViewController alloc] initWithNibName:@"AMOSCMessageViewController" bundle:nil];
    [self fillPanel:panelViewController content:viewController];
    return panelViewController;
}

- (AMPanelViewController *)loadMainOutputPanel:(NSString *)panelId relatedView:(NSView*)view {
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"Main Output" width:UI_defaultPanelWidth* 4 height:UI_defaultPanelHeight relatedView:view];
    NSViewController *viewController = [[AMVisualViewController alloc] initWithNibName:@"AMMainOutputViewController" bundle:nil];
    [self fillPanel:panelViewController content:viewController];
    return panelViewController;
}

- (AMPanelViewController *)loadTimerPanel:(NSString *)panelId relatedView:(NSView*)view{
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"CLOCK" width:UI_defaultPanelWidth height:UI_defaultPanelHeight relatedView:view];
    NSViewController *viewController = [[AMTimerViewController alloc] initWithNibName:@"AMTimerViewController" bundle:nil];
    [self fillPanel:panelViewController content:viewController];
    return panelViewController;
}

- (AMPanelViewController *)loadMusicScorePanel:(NSString *)panelId relatedView:(NSView*)view{
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"MUSIC SCORE" width:UI_defaultPanelWidth height:UI_defaultPanelHeight relatedView:view];
    NSViewController *viewController = [[AMMusicScoreViewController alloc] initWithNibName:@"AMMusicScoreViewController" bundle:nil];
    [self fillPanel:panelViewController content:viewController];
    return panelViewController;
}

- (AMPanelViewController *)loadFOAFPanel:(NSString *)panelId relatedView:(NSView*)view{
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"SOCIAL" width:UI_defaultPanelWidth* 2.0 height:UI_defaultPanelHeight  relatedView:view];
    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
    NSSize panelSize = NSMakeSize(UI_defaultPanelWidth* 2, UI_defaultPanelHeight);
    panelView.minSizeConstraint = panelSize;
    AMSocialViewController *socialViewController = [[AMSocialViewController alloc] initWithNibName:@"AMSocialView" bundle:nil];
    [self fillPanel:panelViewController content:socialViewController];
    [socialViewController.socialWebTab setDrawsBackground:NO];
    [socialViewController loadPage];
    return panelViewController;
}

- (void)initTimer {
    NSTextField *timerField = (NSTextField *) self.amTimer;
    [[AMTimer shareInstance] addTimerScreen:timerField];
}

- (AMPanelViewController *)loadGroupsPanel:(NSString *)panelId relatedView:(NSView*)view {
    float panelWidth = UI_defaultPanelWidth;
    float panelHeight = 340.0f;
    AMPanelViewController *panelViewController = [self createPanel:panelId
                                                         withTitle:@"GROUPS"
                                                             width:panelWidth
                                                            height:panelHeight
                                                  relatedView:view];
    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
    NSSize panelSize = NSMakeSize(300.0f, 220.0f);
    panelView.minSizeConstraint = panelSize;
    AMGroupPanelViewController *userGroupViewController = [[AMGroupPanelViewController alloc] initWithNibName:@"AMUserGroupView" bundle:nil];
    userGroupViewController.view.frame = NSMakeRect(0, UI_panelTitlebarHeight, 300, 380);

    [self fillPanel:panelViewController content:userGroupViewController];
    NSView *groupView = userGroupViewController.view;
    [groupView setTranslatesAutoresizingMaskIntoConstraints:NO];
    return panelViewController;
}

- (AMPanelViewController *)loadPreferencePanel:(NSString *)panelId relatedView:(NSView*)view{
    float panelWidth = UI_defaultPanelWidth* 2;
    float panelHeight = UI_defaultPanelHeight;
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"PREFERENCE"
                                                             width:panelWidth height:panelHeight relatedView:view];
    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
    NSSize panelSize = NSMakeSize(600.0f, UI_defaultPanelHeight);
    panelView.minSizeConstraint = panelSize;
    AMETCDPreferenceViewController *preferenceViewController = [[AMETCDPreferenceViewController alloc] initWithNibName:@"AMETCDPreferenceView" bundle:nil];
    NSView *preferenceView = preferenceViewController.view;
    [self fillPanel:panelViewController content:preferenceViewController];
    [preferenceViewController loadSystemInfo];
    [preferenceView setTranslatesAutoresizingMaskIntoConstraints:NO];
    return panelViewController;


}

- (AMPanelViewController *)loadChatPanel:(NSString *)panelId relatedView:(NSView*)view {
    float panelWidth = 600.0f;
    float panelHeight = 720.0f;

    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"CHAT"
                                                             width:panelWidth height:panelHeight relatedView:view];
    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
    panelView.minSizeConstraint = NSMakeSize(600.0f, 300.0f);
    AMChatViewController *chatViewController = [[AMChatViewController alloc] initWithNibName:@"AMChatView" bundle:nil];
    [self fillPanel:panelViewController content:chatViewController];
    return panelViewController;
}

- (AMPanelViewController *)loadGPlusPanel:(NSString *)panelId relatedView:(NSView*)view {
    float panelWidth = 570.0f; //UI_defaultPanelWidth;
    float panelHeight = UI_defaultPanelHeight; //340.0f;
    
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"G+"
                                                             width:panelWidth height:panelHeight relatedView:view];
    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
    panelView.minSizeConstraint = NSMakeSize(panelWidth, panelHeight);
    AMGPlusViewController *gPlusViewController = [[AMGPlusViewController alloc] initWithNibName:@"AMGPlusViewController" bundle:nil];
    [self fillPanel:panelViewController content:gPlusViewController];
    return panelViewController;
}

- (AMPanelViewController *)loadManualPanel:(NSString *)panelId relatedView:(NSView*)view {
    float panelWidth = UI_defaultPanelWidth*2;
    float panelHeight = UI_defaultPanelHeight;
    
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"MANAUAL"
                                                             width:panelWidth height:panelHeight relatedView:view];
    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
    panelView.minSizeConstraint = NSMakeSize(panelWidth, panelHeight);
    AMManualViewController *manualViewController = [[AMManualViewController alloc] initWithNibName:@"AMManualViewController" bundle:nil];
    [self fillPanel:panelViewController content:manualViewController];
    return panelViewController;
}

- (AMPanelViewController *)createNetworkToolsPanelController:(NSString *)ident
                                                   withTitle:(NSString *)title
                                                relatedView:(NSView*)view{
    float panelWidth = 600.0f;
    float panelHeight = 720.0f;
    AMPanelViewController *panelViewController = [self createPanel:ident withTitle:title width:panelWidth height:panelHeight relatedView:view];
    panelViewController.panelType = AMNetworkToolsPanelType;
    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
    NSSize minSize = NSMakeSize(600.0f, 300);
    panelView.minSizeConstraint = minSize;
    AMNetworkToolsViewController *networkToolsViewController =
    [[AMNetworkToolsViewController alloc] initWithNibName:@"AMNetworkToolsViewController" bundle:nil];
    panelViewController.subViewController = networkToolsViewController;
    NSView *networkToolsView = networkToolsViewController.view;
    networkToolsView.frame = NSMakeRect(0, UI_panelTitlebarHeight, 600, 380);
    [panelView addSubview:networkToolsView];
    [self fillPanel:panelViewController content:networkToolsViewController];
    return panelViewController;
}

- (AMPanelViewController *)loadNetworkToolsPanel:(NSString *)panelId relatedView:(NSView*)view{
    return [self createNetworkToolsPanelController:panelId withTitle:@"NETWORK TOOLS"relatedView:view];
}

- (AMPanelViewController *)loadProfilePanel:(NSString *)panelId relatedView:(NSView*)view{
    float panelHeight = 300.0f;
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"PROFILE" width:UI_defaultPanelWidth height:panelHeight relatedView:view];
    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
    NSSize minSize = NSMakeSize(UI_defaultPanelWidth, UI_defaultPanelWidth);
    panelView.minSizeConstraint = minSize;
    AMUserViewController *userViewController = [[AMUserViewController alloc] initWithNibName:@"AMUserView" bundle:nil];
    NSView *profileView = userViewController.view;
    [panelView addSubview:profileView];
    [self fillPanel:panelViewController content:userViewController];
    return panelViewController;
}

- (IBAction)onSidebarItemClick:(NSButton *)sender {
    NSString *panelId =
            [[NSString stringWithFormat:@"%@_PANEL", sender.identifier] uppercaseString];
    if (sender.state == NSOnState) {
        [self createPanelWithType:panelId withId:panelId];
    }
    else {
        [self removePanel:panelId];
    }
}
- (AMPanelViewController *)createPanelWithType:(NSString *)panelType withId:(NSString *)panelId {
   return  [self createPanelWithType:panelType withId:panelId relatedView:nil];
}

- (AMPanelViewController *)createPanelWithType:(NSString *)panelType withId:(NSString *)panelId relatedView:(NSView*)relatedView{
    AMPanelViewController *panelViewController;
    if ([panelType isEqualToString:UI_Panel_Key_User]) {
        panelViewController = [self loadProfilePanel:panelId relatedView:relatedView];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Groups]) {
        panelViewController = [self loadGroupsPanel:panelId relatedView:relatedView];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Preference]) {
        panelViewController = [self loadPreferencePanel:panelId relatedView:relatedView];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Chat]) {
        panelViewController = [self loadChatPanel:panelId relatedView:relatedView];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_NetworkTools]) {
        panelViewController = [self loadNetworkToolsPanel:panelId relatedView:relatedView];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Map]) {
        panelViewController = [self loadMapPanel:panelId relatedView:relatedView];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Mixing]) {
        panelViewController = [self loadMixingPanel:panelId relatedView:relatedView];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Visual]) {
        panelViewController = [self loadRoutingPanel:panelId relatedView:relatedView];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Social]) {
        panelViewController = [self loadFOAFPanel:panelId relatedView:relatedView] ;
    }
    else if ([panelType isEqualToString:UI_Panel_Key_OSCMessage]) {
        panelViewController = [self loadOSCMessagePanel:panelId relatedView:relatedView];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_MusicScore]) {
        panelViewController = [self loadMusicScorePanel:panelId relatedView:relatedView];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Timer]) {
        panelViewController = [self loadTimerPanel:panelId relatedView:relatedView];
    }
    else if ([panelType isEqualToString:UI_Panel_Key_GPlus]) {
        panelViewController = [self loadGPlusPanel:panelId relatedView:relatedView];
        NSLog(@"UI_Panel_Key_GPlus");
    }
    else if ([panelType isEqualToString:UI_Panel_Key_Manual]) {
        panelViewController = [self loadManualPanel:panelId relatedView:relatedView];
        NSLog(@"UI_Panel_Key_Manual");
    }
    else {
        //TODO:check whether need to load the panel having different panelType.
        // panelViewController=   [self createPanel:panelType withTitle:panelId];
    }
    return panelViewController;

}

- (void)createTabPanelWithType:(NSString *)panelType withTitle:(NSString *)title withPanelId:(NSString *)panelId withTabIndex:(NSInteger)tabIndex from:(AMPanelViewController *)fromController {
    AMPanelViewController *panelViewController = [self createPanelWithType:panelType withId:panelId relatedView:fromController.view];
    if (panelViewController.tabPanelViewController != nil) {
        [panelViewController showAsTabPanel:title withTabIndex:tabIndex];
    }
    panelViewController.movedFromController = fromController;
}


- (IBAction)onTimerControlItemClick:(NSButton *)sender {
    if (sender.state == NSOnState) {
        [[AMTimer shareInstance] start];
    }
    else {
        [[AMTimer shareInstance] pause];
        [[AMTimer shareInstance] reset];
    }
}

- (void)setSideBarItemStatus:(NSString *)identifier withStatus:(Boolean)status {
    NSView *mainView = self.window.contentView;
    for (NSView *subView in mainView.subviews) {
        if ([subView.identifier isEqualToString:@"controlBarContainer"]) {
            for (NSView *subItemView in subView.subviews) {
                NSButton *buttonView = subItemView.subviews[0];
                if (buttonView != nil&& [buttonView.identifier isEqualTo:identifier]) {
                    [buttonView setState:status ? NSOnState : NSOffState];
                    break;
                }
            }
        }
    }
    for (NSView *subView in mainView.subviews) {
        if ([subView isKindOfClass:[BlueBackgroundView class]]) {
            NSButton *buttonView = subView.subviews[0];
            if (buttonView != nil&& [buttonView.identifier isEqualTo:identifier]) {
                [buttonView setState:status ? NSOnState : NSOffState];
                break;
            }
        }
    }
}

- (IBAction)jackServerToggled:(NSButton *)sender
{
    AMAudio* audioModule = [AMAudio sharedInstance];
    if(![audioModule isJackStarted]){
        [self.jackServerBtn setImage:[NSImage imageNamed:@"server_starting"]];
        if (![audioModule startJack])
        {
            [self.jackServerBtn setImage:[NSImage imageNamed:@"Server_on"]];
        }
        
    }else{
        [audioModule stopJack];
    }
}

- (IBAction)oscServerToggled:(id)sender
{
    AMOSCGroups* oscGroups = [AMOSCGroups sharedInstance];
    if(![oscGroups isOSCGroupServerStarted]){
        [self.oscServerBtn setImage:[NSImage imageNamed:@"server_starting"]];
        if (![oscGroups startOSCGroupServer])
        {
            [self.oscServerBtn setImage:[NSImage imageNamed:@"Server_on"]];
        }
        
    }else{
        [oscGroups stopOSCGroupServer];
    }
}

- (IBAction)syphonServerToggled:(id)sender
{
    AMVideo* videoMod= [AMVideo sharedInstance];
    if (![videoMod isSyphonServerStarted]) {
        
        [self.syphonServerBtn setImage:[NSImage imageNamed:@"Server_on"]];
        [videoMod startSyphon];
        
    }else{
        [videoMod stopSyphon];
        [self.syphonServerBtn setImage:[NSImage imageNamed:@"Server_off"]];
    }
}

-(void)jackStarted:(NSNotification*)notification
{
    [self.jackServerBtn setImage:[NSImage imageNamed:@"Server_on"]];
    self.jackCPUUsageBar.hidden = NO;
    self.jackCpuUageNum.hidden = NO;
    
    _jackCpuTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(queryJackCpu) userInfo:nil repeats:YES];
}

-(void)jackStopped:(NSNotification*)notification
{    
    [self.jackServerBtn setImage:[NSImage imageNamed:@"Server_off"]];
    self.jackCPUUsageBar.hidden = YES;
    self.jackCpuUageNum.hidden = YES;
    
    [_jackCpuTimer invalidate];
    _jackCpuTimer = nil;
}

-(void)queryJackCpu
{
    float cpuUsage = [[AMAudio sharedInstance ] jackCpuUsage];
    [self.jackCPUUsageBar setCpuUsage:cpuUsage];
    self.jackCpuUageNum.stringValue = [NSString stringWithFormat:@"%.2f", cpuUsage];
}

-(void)oscStarted:(NSNotification*)notification
{
    [self.oscServerBtn setImage:[NSImage imageNamed:@"Server_on"]];
}

-(void)oscStopped:(NSNotification*)notification
{
    [self.oscServerBtn setImage:[NSImage imageNamed:@"Server_off"]];
}

#pragma mark -
#pragma   mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([object isKindOfClass:[AMTimer class]]) {

        if ([keyPath isEqualToString:@"state"]) {
            AMTimerState newState = [[change objectForKey:@"new"] intValue];

            switch (newState) {
                case kAMTimerStart:
                    [self.amTimerBtn setState:1];
                    break;
                default:
                    [self.amTimerBtn setState:0];
                    break;
            }
        }
    }
}


@end
