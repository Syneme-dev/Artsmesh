//
//  AMMainWindowController.m
//  DemoUI
//
//  Created by xujian on 4/17/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//


#import "AMMainWindowController.h"
//#import <AMPluginLoader/AMPluginAppDelegateProtocol.h>
#import "AMAppDelegate.h"
#import <AMPreferenceManager/AMPreferenceManager.h>
#import "AMPreferenceVC.h"
#import "AMUserViewController.h"
#import "AMSocialViewController.h"
#import <UIFramework/BlueBackgroundView.h>
#import <AMCoreData/AMCoreData.h>
#import "AMChatViewController.h"
#import "AMNetworkToolsViewController.h"
#import "UIFramework/AMBox.h"
#import "UIFramework/AMPanelView.h"
#import "AMMixingViewController.h"
#import "AMVisualViewController.h"
#import "AMMapViewController.h"
#import "AMGroupPanelViewController.h"
#import "AMCoreData/AMCoreData.h"
#import "AMMesher/AMMesher.h"
#import "AMMesher/AMRemoteMesher.h"
#import "AMMesher/AMLocalMesher.h"
#import "AMPanelControlBarViewController.h"
//#import "AMTimer/AMTimer.h"
#import "AMTimerViewController.h"
#import "AMScoreViewController.h"
#import "AMOSCMessageViewController.h"
//#import "AMBroadcastViewController.h"
#import "AMManualViewController.h"
#import "AMAudio/AMAudio.h"
#import "AMOSCGroups/AMOSCGroups.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMCoreData/AMCoreData.h"
#import "AMTimerTabVC.h"

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

#define UI_Panel_Key_Broadcast @"BROADCAST_PANEL"
#define UI_Panel_Key_Manual @"MANUAL_PANEL"

@interface AMMainWindowController ()
@property (weak) IBOutlet NSView *mainContentView;

@property (weak) IBOutlet NSButton *heartbeatMonitor;


@property (weak) IBOutlet AMFoundryFontView *topHourTF;
@property (weak) IBOutlet AMFoundryFontView *topMinTF;
@property (weak) IBOutlet AMFoundryFontView *topSecTF;
@property (nonatomic) NSTimer* topTimer;

@property (nonatomic) double   totalSecond;
@end

@implementation AMMainWindowController {
    AMBox *_containerView;
    //MZTimerLabel *amTimerControl;
    AMPanelControlBarViewController *_controlBarVC;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localMesherMeshed:) name:AM_LOCAL_MESHER_MESHED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localMesherMeshing:) name:AM_LOCAL_MESHER_MESHING_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mesherStopped:) name:AM_MESHER_STOPPED_NOTIFICATION object:nil];
     
        //Notification for the Heartbeat Monitor
        [[NSNotificationCenter defaultCenter]
                                    addObserver:self
                                        selector:@selector(heartbeatBlink:)
                                        name:AMHeartbeatNotification
                                        object:nil];
        
        [[NSNotificationCenter defaultCenter]
                                    addObserver:self
                                        selector:@selector(heartbeatBlink:)
                                        name:AMHeartbeatFailNotification
                                         object:nil];
        
        [[NSNotificationCenter defaultCenter]
                                    addObserver:self
                                        selector:@selector(heartbeatBlink:)
                                        name:AMHeartbeatDisconnectNotification
                                        object:nil];
        
        [[NSNotificationCenter defaultCenter]
                                    addObserver:self
                                        selector:@selector(localHeartbeatBlink:)
                                        name:AMLocalHeartbeatNotification
                                        object:nil];
        [[NSNotificationCenter defaultCenter]
                                    addObserver:self
                                        selector:@selector(localHeartbeatBlink:)
                                        name:AMLocalHeartbeatFailNotification
                                        object:nil];
        [[NSNotificationCenter defaultCenter]
                                    addObserver:self
                                        selector:@selector(localHeartbeatBlink:)
                                        name:AMLocalHeartbeatDisconnectNotification
                                        object:nil];
        

        
        //Add for top bar timer
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startTopTimer:)
                                                     name:AMTimerStartNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopTopTimer:)
                                                     name:AMTimerStopNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pauseTopTimer:)
                                                     name:AMTimerPauseNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resumeTopTimer:)
                                                     name:AMTimerResumeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeTheme:)
                                                     name:@"AMThemeChanged"
                                                   object:nil];
        
        _curTheme = [AMTheme sharedInstance];
    }
    return self;
}


- (void)windowWillClose:(NSNotification *)notification {
    
    [self archeivePanelLocation];
    
    [self closeJackClient];
}


-(void)archeivePanelLocation
{
    NSMutableArray *panelViewArcheive = [[NSMutableArray alloc] init];
    for(int col = 0; col < [_containerView.subviews count]; col++){
        
        NSView * colView = [_containerView.subviews objectAtIndex:col];
        NSMutableArray *rowViews = [[NSMutableArray alloc] init];
        for (int row = 0; row < [colView.subviews count]; row ++) {

            NSView *panelView = [colView.subviews objectAtIndex:row];
            if ([panelView isKindOfClass:[AMPanelView class]]) {
                AMPanelView *pView = (AMPanelView *)panelView;
                
                NSString *pId = @"";
                if ([pView.panelViewController isKindOfClass:[AMPanelViewController class]]) {
                    AMPanelViewController *controller = (AMPanelViewController*)pView.panelViewController;
                    pId = controller.panelId;
                }
                
                NSDictionary *locDict = @{
                                          @"column" : [NSNumber numberWithInt:col],
                                          @"row" :  [NSNumber numberWithInt:row],
                                          @"width": [NSNumber numberWithFloat:panelView.frame.size.width],
                                          @"height":[NSNumber numberWithFloat:panelView.frame.size.height],
                                          @"panelId": pId
                                        };
                
               // NSLog(@"%@", pId);
                
                [rowViews addObject:locDict];
            }
        }
        
        if([rowViews count] != 0){
            [panelViewArcheive addObject:rowViews];
        }
    }
    
    [[AMPreferenceManager standardUserDefaults] setObject:panelViewArcheive forKey:UserData_Key_OpenedPanel];
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
    NSScrollView *scrollView = self.mainScrollView;
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



#pragma mark -
#pragma Create Main Window

#define Main_Window_Leading     10.0f
#define Main_Window_Trailing    10.0f
#define Main_Window_Top         40.0f
#define Main_Window_Bottom      40.0f

#define Main_View_Top           60.0f

#define TopBar_Leading          450.0f

#define LeftBar_Leading         0.0f
#define LeftBar_Top             (20.0f + Main_View_Top)


- (void)showDefaultWindow {
    isWindowLoading = YES;
    
    [self createMainWindow];
    [self createMainScrollView];
    [self createMainBox];
    
    [self loadVersion];
    [self loadControlBar];
    
    [self loadLastOpenedPanels];
    
    isWindowLoading = NO;
    
}


-(void)createMainWindow
{
    NSRect screenRect = [NSScreen mainScreen].frame;
    NSRect windowRect = NSMakeRect(Main_Window_Leading,
                                   Main_Window_Bottom,
                                   screenRect.size.width - Main_Window_Leading - Main_Window_Trailing,
                                   screenRect.size.height - Main_Window_Top - Main_Window_Bottom);
    
    [self.window setFrame:windowRect display:YES];
}


-(void)createMainScrollView
{
    NSSize windowSize = [self.window.contentView frame].size;
    self.mainScrollView.frame = NSMakeRect(UI_leftSidebarWidth+ 10,
                                           0,
                                           windowSize.width - UI_leftSidebarWidth,
                                           windowSize.height - UI_topbarHeight- 20);
    
    [self.mainScrollView setHorizontalLineScroll:100];
    [self.mainScrollView setBackgroundColor:_curTheme.colorBackground];
    [self.mainScrollView setNeedsDisplay:YES];
}


- (void)createMainBox
{
    _containerView = [AMBox hbox];
    _containerView.frame = self.mainScrollView.bounds;
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
    
    [self.mainScrollView setDocumentView:_containerView];
    [self windowDidResize:nil];  // temporary resolution
}


- (void)loadVersion
{
    NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    [self.versionLabel setStringValue:[NSString stringWithFormat:@"%@", shortVersion]];
}


-(void)loadControlBar
{
    [self createControlbar];
    [self addContrainsToControlBar];
    [self loadControlBarStatus];
}


-(void)createControlbar
{
    if (_controlBarVC) {
        [_controlBarVC.view removeFromSuperview];
    }
    
    NSSize windowSize = [self.window.contentView frame].size;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:Preference_Key_General_TopControlBar]) {
        NSPoint point = NSMakePoint(TopBar_Leading, windowSize.height - Main_View_Top);
        _controlBarVC = [[AMPanelControlBarViewController alloc] initWithNibName:@"PanelControlBarView" bundle:nil];
        [_controlBarVC.view setFrameOrigin:point];
    }
    else {
        
        _controlBarVC = [[AMPanelControlBarViewController alloc] initWithNibName:@"VerticalControlBarView" bundle:nil];
        NSPoint point = NSMakePoint(LeftBar_Leading, windowSize.height - LeftBar_Top - _controlBarVC.view.frame.size.height);
        [_controlBarVC.view setFrameOrigin:point];
    }
    
    [self.window.contentView addSubview:_controlBarVC.view];
}


-(void)addContrainsToControlBar
{
    NSView *contentView = [self.window contentView];
    NSView *customView = self.mainScrollView;
    [customView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
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
    [self.mainScrollView removeConstraints:self.mainScrollView.constraints];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:Preference_Key_General_TopControlBar]) {
        [contentView addConstraints:constraints50];
    }
    else {
        [contentView addConstraints:constraints10];
    }
}


-(void)loadControlBarStatus
{
    for(NSMutableArray* panels in [[AMPreferenceManager standardUserDefaults] objectForKey:UserData_Key_OpenedPanel]){
        if (panels != nil && [panels isKindOfClass:[NSMutableArray class]]) {
            for (NSDictionary *dict in panels) {
                NSString *panelId = [dict objectForKey:@"panelId"];
                NSString *sideItemId = [panelId stringByReplacingOccurrencesOfString:@"_PANEL" withString:@""];
                [self setSideBarItemStatus:sideItemId withStatus:YES ];
            }
        }
    }
}


-(void)loadLastOpenedPanels
{
    for(NSMutableArray* panels in [[AMPreferenceManager standardUserDefaults] objectForKey:UserData_Key_OpenedPanel]){
        if (panels != nil && [panels isKindOfClass:[NSMutableArray class]]) {
            for (NSDictionary *dict in panels) {
                NSString *panelId = [dict objectForKey:@"panelId"];
                [self createPanelWithId:panelId];
            }
        }
    }
}


#pragma Creat Main Window End
#pragma mark-



-(AMPanelViewController*)createPanelWithId:(NSString *)panelId
{
    AMPanelViewController* panelCtrl = [self createPanelWithType:panelId withId:panelId relatedView:nil];
    return panelCtrl;
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
    NSScrollView *scrollView = self.mainScrollView;
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
//    NSMutableArray *openedPanels = [[[AMPreferenceManager standardUserDefaults] objectForKey:UserData_Key_OpenedPanel] mutableCopy];
//    if (![openedPanels containsObject:identifier]) {
//        [openedPanels addObject:identifier];
//    }

    //[[AMPreferenceManager standardUserDefaults] setObject:openedPanels forKey:UserData_Key_OpenedPanel];
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


//- (AMPanelViewController *)loadTestPanel {
//    AMPanelViewController *panelViewController = [self createPanel:@"TEST_PANEL" withTitle:@"test"];
//    AMTestViewController *testViewController = [[AMTestViewController alloc] initWithNibName:@"AMTestView" bundle:nil];
//    [self fillPanel:panelViewController content:testViewController];
//    return panelViewController;
//}


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
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"OSC CLIENT" width:UI_defaultPanelWidth*2.5 height:UI_defaultPanelHeight relatedView:view];
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
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"NETRONOME" width:760 height:UI_defaultPanelHeight relatedView:view];
//    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
//    panelView.minSizeConstraint = panelView.frame.size;
    NSViewController *viewController = [[AMTimerViewController alloc] initWithNibName:@"AMTimerViewController" bundle:nil];
    [self fillPanel:panelViewController content:viewController];
    return panelViewController;
}


- (AMPanelViewController *)loadMusicScorePanel:(NSString *)panelId relatedView:(NSView*)view{
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"SCORE" width:UI_defaultPanelWidth*4 height:UI_defaultPanelHeight relatedView:view];
   
    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
    NSSize panelSize = NSMakeSize(UI_defaultPanelWidth, UI_defaultPanelWidth);
    panelView.minSizeConstraint = panelSize;
    
    NSViewController *viewController = [[AMScoreViewController alloc] initWithNibName:@"AMScoreViewController" bundle:nil];
    [self fillPanel:panelViewController content:viewController];
    return panelViewController;
    
}


- (AMPanelViewController *)loadFOAFPanel:(NSString *)panelId relatedView:(NSView*)view{
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"SOCIAL" width:UI_defaultPanelWidth* 3.5 height:UI_defaultPanelHeight  relatedView:view];
    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
    NSSize panelSize = NSMakeSize(UI_defaultPanelWidth* 2, UI_defaultPanelHeight);
    panelView.minSizeConstraint = panelSize;
    AMSocialViewController *socialViewController = [[AMSocialViewController alloc] initWithNibName:@"AMSocialView" bundle:nil];
    [self fillPanel:panelViewController content:socialViewController];
    [socialViewController.socialWebTab setDrawsBackground:NO];
    [socialViewController loadPage];
    return panelViewController;
}

/*
- (void)initTimer {
    NSTextField *timerField = (NSTextField *) self.amTimer;
    [[AMTimer shareInstance] addTimerScreen:timerField];
}*/


- (AMPanelViewController *)loadGroupsPanel:(NSString *)panelId relatedView:(NSView*)view {
    float panelWidth = UI_defaultPanelWidth*1.5;
    float panelHeight = 340.0f;
    AMPanelViewController *panelViewController = [self createPanel:panelId
                                                         withTitle:@"GROUPS"
                                                             width:panelWidth
                                                            height:panelHeight
                                                  relatedView:view];
    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
    NSSize panelSize = NSMakeSize(UI_defaultPanelWidth *1.5, 220.0f);
    panelView.minSizeConstraint = panelSize;
    AMGroupPanelViewController *userGroupViewController = [[AMGroupPanelViewController alloc] initWithNibName:@"AMGroupPanelViewController" bundle:nil];
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
    AMPreferenceVC *preferenceViewController = [[AMPreferenceVC alloc] initWithNibName:@"AMPreferenceVC" bundle:nil];
    NSView *preferenceView = preferenceViewController.view;
    [self fillPanel:panelViewController content:preferenceViewController];
    [preferenceView setTranslatesAutoresizingMaskIntoConstraints:NO];
    return panelViewController;
}


- (AMPanelViewController *)loadChatPanel:(NSString *)panelId relatedView:(NSView*)view {
    float panelWidth = 600.0f;
    float panelHeight = 720.0f;

    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"OSCHAT"
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
    
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"BROADCAST"
                                                             width:panelWidth height:panelHeight relatedView:view];
    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
    panelView.minSizeConstraint = NSMakeSize(panelWidth, panelHeight);
 //   AMBroadcastViewController *gPlusViewController = [[AMBroadcastViewController alloc] initWithNibName:@"AMBroadcastViewController" bundle:nil];
   // [self fillPanel:panelViewController content:gPlusViewController];
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


-(void)createPanel:(NSString *)panelId withTitle:(NSString *)title relateView:(NSView *)view size:(NSSize)panelSize minSize:(NSSize)minSize
           maxSize: (NSSize) maxSize nibName:(NSString *)nibName
{
    AMPanelViewController *panelViewController = [self createPanel:panelId
                                                         withTitle:title
                                                             width:panelSize.width
                                                            height:panelSize.height
                                                       relatedView:view];
    panelViewController.panelType = AMNetworkToolsPanelType;
    AMPanelView *panelView = (AMPanelView *) panelViewController.view;
    panelView.minSizeConstraint = minSize;
    NSViewController *viewController = [[NSViewController alloc] initWithNibName:nibName bundle:nil];
    panelViewController.subViewController = viewController;
    viewController.view.frame = NSMakeRect(0, UI_panelTitlebarHeight, 600, 380);
    [panelView addSubview:viewController.view];
    [self fillPanel:panelViewController content:viewController];
}


- (AMPanelViewController *)loadNetworkToolsPanel:(NSString *)panelId relatedView:(NSView*)view{
    return [self createNetworkToolsPanelController:panelId withTitle:@"NETWORK TOOLS"relatedView:view];
}


- (AMPanelViewController *)loadProfilePanel:(NSString *)panelId relatedView:(NSView*)view{
    float panelHeight = 300.0f;
    AMPanelViewController *panelViewController = [self createPanel:panelId withTitle:@"PROFILE" width:UI_defaultPanelWidth*1.5 height:panelHeight relatedView:view];
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
    else if ([panelType isEqualToString:UI_Panel_Key_Broadcast]) {
        panelViewController = [self loadGPlusPanel:panelId relatedView:relatedView];
        NSLog(@"UI_Panel_Key_Broadcast");
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

/*
- (IBAction)onTimerControlItemClick:(NSButton *)sender {
    if (sender.state == NSOnState) {
        [[AMTimer shareInstance] start];
    }
    else {
        [[AMTimer shareInstance] pause];
        [[AMTimer shareInstance] reset];
    }
}
*/

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
    AMAudio*        audioModule = [AMAudio sharedInstance];
    AMJackClient*   client      = [audioModule audioJackClient];
    
    if(![audioModule isJackStarted]){
        [self.jackServerBtn setImage:[NSImage imageNamed:@"server_starting"]];
        if (![audioModule startJack])
        {
            [self.jackServerBtn setImage:[NSImage imageNamed:@"Server_on"]];
        }
        
        [client openJackClient];
    }else{
        [self closeJackClient];
    }
}

- (void) closeJackClient
{
    AMAudio*        audioModule = [AMAudio sharedInstance];
    AMJackClient*   client      = [audioModule audioJackClient];
  
    if([audioModule isJackStarted]){
        [client closeJackClient];
        [audioModule stopJack];
    }
}

- (IBAction)oscServerToggled:(id)sender
{
    AMOSCGroups* oscGroups = [AMOSCGroups sharedInstance];
    if(![oscGroups isOSCGroupServerStarted]){
        [self.oscServerBtn setImage:[NSImage imageNamed:@"server_starting"]];
        [oscGroups startOSCGroupServer];
    }else{
        [oscGroups stopOSCGroupServer];
    }
}


- (IBAction)syphonServerToggled:(id)sender
{
/*    AMVideo* videoMod= [AMVideo sharedInstance];
    if (![videoMod isSyphonServerStarted]) {
        
        [self.syphonServerBtn setImage:[NSImage imageNamed:@"Server_on"]];
        [videoMod startSyphon];
        
    }else{
        [videoMod stopSyphon];
        [self.syphonServerBtn setImage:[NSImage imageNamed:@"Server_off"]];
    }*/
}

- (IBAction)localMesherToggled:(id)sender {
    // Time to Start/Stop the Local Mesher process

    AMMesher *curMesher = [AMMesher sharedAMMesher];
    switch (curMesher.clusterState) {
        case kClusterStarted:
            // Mesher currently started - need to stop
            [curMesher stopMesher];
            break;
        case kClusterStopped:
            // Mesher currently stopped - need to start it up!
            [curMesher startMesher];
            break;
        //In default state, most of them are between start but not yet successfuly finished.
        // In the case of start, there is two seconds sleep after executing bash command,
        // it wouldn't success during this time.
        default:
            [curMesher stopMesher];
            break;
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
    [AMCoreData shareInstance].mySelf.oscServer = YES;
    [[AMMesher sharedAMMesher] updateMySelf];

}


-(void)oscStopped:(NSNotification*)notification
{
    [self.oscServerBtn setImage:[NSImage imageNamed:@"Server_off"]];
    [AMCoreData shareInstance].mySelf.oscServer = NO;
    [[AMMesher sharedAMMesher] updateMySelf];
}

-(void)localMesherMeshing:(NSNotification *)notification {
    [self.localMesherBtn setImage:[NSImage imageNamed:@"server_starting"]];
}

-(void)localMesherMeshed:(NSNotification *)notification {
    //User locally meshed successfully
    [self.localMesherBtn setImage:[NSImage imageNamed:@"Server_on"]];
    
    //AMLiveGroup *myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    AMLiveUser *mySelf = [AMCoreData shareInstance].mySelf;
    
    if (mySelf.isLeader && [[NSUserDefaults standardUserDefaults] boolForKey:Preference_Key_General_MeshUseIpv6]) {
        [self.meshUseIpv6TextField setStringValue:@"6"];
    }
    
}

-(void)mesherStopped:(NSNotification *)notification {
    //Mesher service has stopped.
    [self.localMesherBtn setImage:[NSImage imageNamed:@"Server_off"]];
    
    [self.meshUseIpv6TextField setStringValue:@""];
}


#pragma mark -
#pragma mark Top bar timer

- (void) displayTopTimer:(NSTimeInterval) timeInterval
{
    int hours = timeInterval / 3600.0;
    [self.topHourTF setStringValue:[NSString stringWithFormat:@"%02d", hours]];
    timeInterval -= hours * 3600.0;
    
    int minutes = timeInterval / 60.0;
    [self.topMinTF setStringValue:[NSString stringWithFormat:@"%02d", minutes]];
    timeInterval -= minutes * 60.0;
    
    int seconds = (int)timeInterval;
    [self.topSecTF setStringValue:[NSString stringWithFormat:@"%02d", seconds]];
}

- (void) increaseSecond
{
    self.totalSecond++;
    [self displayTopTimer:self.totalSecond];
}

- (void) startTopTimer:(NSNotification*) notification
{
    static  NSTimeInterval interval = 1;
    self.topTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                     target:self
                                                   selector:@selector(increaseSecond)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void)stopTopTimer:(NSNotification *)notification
{
    [self.topTimer invalidate];
    self.totalSecond = 0.0;
    
    [self displayTopTimer:self.totalSecond];
}

- (void)pauseTopTimer:(NSNotification *)notification
{
    [self.topTimer invalidate];
}


- (void)resumeTopTimer:(NSNotification *)notification
{
    NSTimeInterval duration = [notification.userInfo[@"Duration"] floatValue];
    self.totalSecond = duration;
    [self startTopTimer:notification];
/*    NSInteger metronomeValue = ((NSInteger)duration) % self.upperNumber.intValue + 1;
    self.metronomeLabel.stringValue = @(metronomeValue).stringValue;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.metronomeTimeInterval
                                                  target:self
                                                selector:@selector(incrementMetronome)
                                                userInfo:nil
                                                 repeats:YES];
    self.timer.fireDate = [[NSDate date] dateByAddingTimeInterval:1.0];*/
}

#pragma mark -
#pragma mark Heartbeat Monitor Blink

- (void) heartbeatBlinkYellow : (NSNotification*) notfication
{
//    //Now just
    [self.heartbeatMonitor setImage:[NSImage imageNamed:@"Server_on"]];
    [self.heartbeatMonitor setNeedsDisplay:YES];
    
    [NSThread sleepForTimeInterval:0.2];
    [self.heartbeatMonitor setImage:[NSImage imageNamed:@"Server_off"]];
    [self.heartbeatMonitor setNeedsDisplay:YES];
}

- (void) heartbeatBlink : (NSNotification*) notfication
{
    if([notfication.name
        isEqualToString:AMHeartbeatNotification]) {
        [self.heartbeatMonitor setImage:
                [NSImage imageNamed:@"groupuser_meshed_icon"]];
    }else if([notfication.name
              isEqualToString:AMHeartbeatFailNotification]){
        [self.heartbeatMonitor setImage:
                [NSImage imageNamed:@"groupuser_busy"]];
    }else if([notfication.name
              isEqualToString:AMHeartbeatDisconnectNotification]){
        [self.heartbeatMonitor setImage:
                [NSImage imageNamed:@"project_broadcast"]];
    }else {
        return;
    }
   
    [self.heartbeatMonitor setNeedsDisplay:YES];
    
    [NSThread sleepForTimeInterval:0.2];
    [self.heartbeatMonitor setImage:[NSImage imageNamed:@"black_dot"]];
    [self.heartbeatMonitor setNeedsDisplay:YES];
}

- (void) localHeartbeatBlink : (NSNotification *) notification {
    
    AMMesher *curMesher = [AMMesher sharedAMMesher];
    switch (curMesher.clusterState) {
        case kClusterStarted:
            if ([notification.name isEqualToString:AMLocalHeartbeatFailNotification]) {
                // Heartbeat failed while meshed, notify user
                
                [self.localMesherBtn setImage:[NSImage imageNamed:@"server_starting"]];
                
                [self.localMesherBtn setNeedsDisplay:YES];
                
                
            }
            
            [NSThread sleepForTimeInterval:0.2];
            
            [self.localMesherBtn setImage:[NSImage imageNamed:@"Server_on"]];
            [self.localMesherBtn setNeedsDisplay:YES];
            
            break;
        default:
            break;
    }

}

- (void) changeTheme:(NSNotification *) notification {
    //[self.mainScrollView setBackgroundColor:[AMTheme sharedInstance].colorBackground];
    [self.window.contentView setNeedsDisplay:YES];
    
    //Update main scroll view background color
    [self.mainScrollView setBackgroundColor:_curTheme.colorBackground];
    [self.mainScrollView setNeedsDisplay:YES];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
