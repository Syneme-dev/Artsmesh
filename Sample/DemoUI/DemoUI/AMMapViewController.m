//
//  AMMapViewController.m
//  DemoUI
//
//  Created by xujian on 6/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMMapViewController.h"
#import "AMCoreData/AMCoreData.h"

#import <Cocoa/Cocoa.h>

#import "AMPreferenceManager/AMPreferenceManager.h"
#import <WebKit/WebKit.h>
#import <UIFramework/AMButtonHandler.h>


#import <AMNotificationManager/AMNotificationManager.h>
#import "AMRestHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import <UIFramework/AMButtonHandler.h>
#import "AMMesher/AMMesher.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMMesher/AMMesher.h"
#import "AMUserLogonViewController.h"
#import "UIFrameWork/AMCheckBoxView.h"
#import "AMStatusNet/AMStatusNet.h"
#import "UIFrameWork/AMFoundryFontView.h"
#import "AMGroupCreateViewController.h"
#import "AMFloatPanelViewController.h"
#import "AMFloatPanelView.h"

#define UI_Text_Color_Gray [NSColor colorWithCalibratedRed:(152/255.0f) green:(152/255.0f) blue:(152/255.0f) alpha:1]

@interface AMMapViewController ()
{
    NSString* statusNetURLString;
    NSString* statusNetGroupURLString;
    NSString* statusNetProfileURLString;
}

@end

@implementation AMMapViewController

@synthesize liveMapView = _liveMapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    self.archiveScale=1;
    [self.tabs setAutoresizesSubviews:YES];
    [self.archiveWebView setFrameLoadDelegate:self];
    [self.archiveWebView setPolicyDelegate:self];
    [self.archiveWebView setUIDelegate:self];
    [self.archiveWebView setDrawsBackground:NO];
    [self loadLivePage];
    [self loadArchivePage];
    [AMButtonHandler changeTabTextColor:self.staticTab toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.liveTab toColor:UI_Color_blue];
    [self liveTabClick:self.liveTab];
}
- (IBAction)smallerButtonClick:(id)sender {
    if(self.archiveScale<0.5f){
        return;
    }
    self.archiveScale-=0.1f;
    NSString *scriptString=[NSString stringWithFormat:@"$('#circle')[0].contentDocument.documentElement.style.zoom = \"%f\";document.documentElement.style.zoom = \"%f\"",self.archiveScale,self.archiveScale ];
     [self.archiveWebView stringByEvaluatingJavaScriptFromString:scriptString];
}
- (IBAction)largerButtonClick:(id)sender {
    self.archiveScale+=0.1f;
    NSString *scriptString=[NSString stringWithFormat:@"$('#circle')[0].contentDocument.documentElement.style.zoom = \"%f\";document.documentElement.style.zoom = \"%f\"",self.archiveScale,self.archiveScale ];
    [self.archiveWebView stringByEvaluatingJavaScriptFromString:scriptString];
}

-(void)registerTabButtons{
    super.tabs=self.tabs;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.liveTab];
    [self.tabButtons addObject:self.staticTab];
    self.showingTabsCount=2;
    
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    if( [sender isEqual:self.archiveWebView] ) {
        [listener use];
        NSString *requestString = [[request URL] absoluteString];
        NSArray *components = [requestString componentsSeparatedByString:@":"];
        
        if ([components count] > 1 &&
            [(NSString *)[components objectAtIndex:0] isEqualToString:@"app"]) {
            
            if([(NSString *)[components objectAtIndex:1] isEqualToString:@"nodeClick"])
            {
                if ([components count]==4&&[[components objectAtIndex:2] isEqualToString:@"group"]) {
                    NSString *groupName=[components objectAtIndex:3];
                    [self groupClicked:groupName];
                }
                else{
                NSString *nodeName=[components objectAtIndex:2];
                [self elementClicked:nodeName];
                }
            }

        }
        
    }
    else {
        [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
        [listener ignore];
        
    }
}

-(void)dealloc{
    //To avoid a error when closing
    [self.archiveWebView.mainFrame stopLoading];
    
}

-(void)webViewClose:(WebView *)sender
{
    [self.archiveWebView.mainFrame stopLoading];
    [self.archiveWebView cancelOperation:nil];
    [super webViewClose:sender];
}

//Note:working for enable to open external link with new web browser.
- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener {
    [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
    [listener ignore];
}

-(void)loadLivePage {

    NSTabViewItem *mapTab = [self.tabs tabViewItemAtIndex:0];
    NSView *contentView = mapTab.view;
    
    AMLiveMapView *mapView = [[AMLiveMapView alloc] initWithFrame:self.view.bounds];
    _liveMapView = mapView;
    [_liveMapView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [contentView addSubview: _liveMapView];
    
    _liveMapView.translatesAutoresizingMaskIntoConstraints = NO;

    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subView]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:@{@"subView" : _liveMapView}];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"subView" : _liveMapView}];
    
    [contentView addConstraints:verticalConstraints];
    [contentView addConstraints:horizontalConstraints];
    
}

- (void)loadArchivePage
{
    
    //TODO:there is an errror when load social and map at the same time.
    //Error:There was a problem with your session token.
    //TODO:the social panel may change the map panel css style .
    
    //    isLogin=false;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    statusNetURLString= [defaults stringForKey:Preference_Key_StatusNet_URL];
    NSURL *mapURL = [NSURL URLWithString:
                     [NSString stringWithFormat:@"%@/app/archive-events.html?fromMac=true",statusNetURLString ]];
    [self.archiveWebView.mainFrame loadRequest:
    [NSURLRequest requestWithURL:mapURL]];
    
    [self createArchiveFloatWindow];
}

-(void)createArchiveFloatWindow {
    //display test float panel
    
    //Create float panel controller + view
    AMFloatPanelViewController *fpc = [[AMFloatPanelViewController alloc] initWithNibName:@"AMFloatPanelView" bundle:nil andSize:NSMakeSize(400, 300) andTitle:@"ARCHIVE" andTitleColor:UI_Text_Color_Gray];
    _floatPanelViewController = fpc;
    
    _archiveFloatWindow = fpc.containerWindow;
    _archiveFloatWindow.level = NSFloatingWindowLevel;
}


-(void) loadGroupWebView:(NSString *)groupName {
    WebView *group_webview = [[WebView alloc] initWithFrame:NSMakeRect(0, 16, _floatPanelViewController.panelContent.frame.size.width -20, _floatPanelViewController.panelContent.frame.size.height-20)];
    [group_webview setFrameLoadDelegate:self];
    
    [group_webview setDrawsBackground:NO];
    _floatWindowWebView = group_webview;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    statusNetProfileURLString = [defaults stringForKey:Preference_Key_StatusNet_URL];
    NSURL *group_url = [NSURL URLWithString:
                          [NSString stringWithFormat:@"%@/group/%@?fromMac=true",statusNetURLString ,groupName]];
    [group_webview.mainFrame loadRequest:
     [NSURLRequest requestWithURL:group_url]];
    
    [_floatPanelViewController.panelContent addSubview:group_webview];
    
    //set up constraints
    
    group_webview.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subView]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:@{@"subView" : group_webview}];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"subView" : group_webview}];
    
    [_archiveFloatWindow.contentView addConstraints:verticalConstraints];
    [_archiveFloatWindow.contentView addConstraints:horizontalConstraints];
}

-(void) loadProfileWebView:(NSString*)userName {
    WebView *profile_webview = [[WebView alloc] initWithFrame:NSMakeRect(0, 16, _floatPanelViewController.panelContent.frame.size.width -20, _floatPanelViewController.panelContent.frame.size.height-20)];
    [profile_webview setFrameLoadDelegate:self];
    
    [profile_webview setDrawsBackground:NO];
    _floatWindowWebView = profile_webview;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    statusNetProfileURLString = [defaults stringForKey:Preference_Key_StatusNet_URL];
    NSURL *profile_url = [NSURL URLWithString:
                          [NSString stringWithFormat:@"%@/%@?fromMac=true",statusNetURLString ,userName]];
    statusNetProfileURLString = [profile_url absoluteString];
    [profile_webview.mainFrame loadRequest:
     [NSURLRequest requestWithURL:profile_url]];
    
    [_floatPanelViewController.panelContent addSubview:profile_webview];

    //set up constraints
    
    profile_webview.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subView]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:@{@"subView" : profile_webview}];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"subView" : profile_webview}];
    
    [_archiveFloatWindow.contentView addConstraints:verticalConstraints];
    [_archiveFloatWindow.contentView addConstraints:horizontalConstraints];
}


-(void)gotoUsersPage{
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    
    NSString *url= sender.mainFrameURL;
    sender.preferences.userStyleSheetEnabled = YES;
    NSString *path= [[NSBundle mainBundle] bundlePath];
    if([frame.DOMDocument.documentURI containsString:@"www.youtube.com/embed"])
    {
        return;
    }
    
    if ( statusNetProfileURLString && [url hasPrefix:statusNetProfileURLString]) {
        [sender setPreferencesIdentifier:@"floatWindowPrefs"];
        path=[path stringByAppendingString:@"/Contents/Resources/archive-popup-info.css"];
        sender.preferences.userStyleSheetLocation = [NSURL fileURLWithPath:path];
        
        NSString *loginJs = @"$('<div class=\"section\" id=\"eventSection\"><h2>Event</h2></div>').appendTo('#aside_primary');$('.eventItem').appendTo('#eventSection');";
        [frame.webView stringByEvaluatingJavaScriptFromString:
         loginJs];
        
    }
    else if ( statusNetGroupURLString && [url hasPrefix:statusNetGroupURLString]) {
        [sender setPreferencesIdentifier:@"floatWindowPrefs"];
        path=[path stringByAppendingString:@"/Contents/Resources/archive-popup-info.css"];
        sender.preferences.userStyleSheetLocation = [NSURL fileURLWithPath:path];
        
    }
    else if([url hasPrefix:statusNetURLString]){
        path=[path stringByAppendingString:@"/Contents/Resources/map.css"];
        sender.preferences.userStyleSheetLocation = [NSURL fileURLWithPath:path];
    }
    else {
        sender.preferences.userStyleSheetEnabled = NO;
    }
    //
}

- (void)windowDidLoad{

}
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector{
    if (aSelector == @selector(elementClicked:)) return NO;
    return YES;
}
+ (BOOL)isKeyExcludedFromWebScript:(const char *)name{

        return NO;


}

-(void)groupClicked:(NSString *)groupName{
    //NSLog (groupName);
    [_floatPanelViewController.panelContent setSubviews: [NSArray array]];
    
    [self loadGroupWebView:groupName];
    
    [_archiveFloatWindow setBackgroundColor:[NSColor blueColor]];
    [_archiveFloatWindow makeKeyAndOrderFront:NSApp];
}

-(void)elementClicked:(NSString *)userName{
    [_floatPanelViewController.panelContent setSubviews: [NSArray array]];
    
    [self loadProfileWebView:userName];
    
    [_archiveFloatWindow setBackgroundColor:[NSColor blueColor]];
    [_archiveFloatWindow makeKeyAndOrderFront:NSApp];
    
}




- (IBAction)onStaticTabClick:(id)sender {
    [self pushDownButton:self.staticTab];
    [self.tabs selectTabViewItemAtIndex:1];
}
- (IBAction)liveTabClick:(id)sender {
    [self pushDownButton:self.liveTab];
    [self.tabs selectTabViewItemAtIndex:0];
}
@end
