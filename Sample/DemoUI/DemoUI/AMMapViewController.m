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


@interface AMMapViewController ()
{
    NSString* statusNetURLString;
}

@end

@implementation AMMapViewController

@synthesize liveMapView = _liveMapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
                // Initialization code here.
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
                     [NSString stringWithFormat:@"%@?fromMac=true",statusNetURLString ]];
    [self.archiveWebView.mainFrame loadRequest:
    [NSURLRequest requestWithURL:mapURL]];
    
    [self createArchiveFloatWindow];
}

-(void)createArchiveFloatWindow {
    //display test float panel
    
    //Create float panel controller + view
    AMFloatPanelViewController *fpc = [[AMFloatPanelViewController alloc] initWithNibName:@"AMFloatPanelView" bundle:nil andSize:NSMakeSize(400, 300) andTitle:@"ARCHIVE"];
    _floatPanelViewController = fpc;
    
    _archiveFloatWindow = fpc.containerWindow;
}

- (WebView *)embedYouTube:(NSString *)urlString frame:(NSRect)frame {
    
    self.youTubeVideo = [[WebView alloc] initWithFrame:frame];
    [[self.youTubeVideo mainFrame] loadRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:urlString]]];
    [self.youTubeVideo setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    return self.youTubeVideo;
}

-(void)displayArchiveProgram {
    [_floatPanelViewController.panelContent setSubviews: [NSArray array]];
    
    [_floatPanelViewController.panelContent addSubview:[self embedYouTube:@"https://www.youtube.com/embed/gm9a28J67E4" frame:NSMakeRect(0, 0, _floatPanelViewController.panelContent.frame.size.width, _floatPanelViewController.panelContent.frame.size.height)]];
    
    [_archiveFloatWindow setBackgroundColor:[NSColor blueColor]];
    [_archiveFloatWindow makeKeyAndOrderFront:NSApp];
}

-(void)gotoUsersPage{
//    NSURL *baseURL =
//    [NSURL URLWithString:
//     [NSString stringWithFormat:@"%@/directory/users?fromMac=true",statusNetURL ]];
//    [self.socialWebTab.mainFrame loadRequest:
//     [NSURLRequest requestWithURL:baseURL]];
}



- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    NSString *url= sender.mainFrameURL;
    self.archiveWebView.preferences.userStyleSheetEnabled = YES;
    NSString *path= [[NSBundle mainBundle] bundlePath];
   if([url hasPrefix:statusNetURLString]){
        path=[path stringByAppendingString:@"/Contents/Resources/map.css"];
    }
    else{
        self.archiveWebView.preferences.userStyleSheetEnabled = NO;
    }
    
    [[self.archiveWebView windowScriptObject] setValue:self forKey:@"objcConnector"];
    self.archiveWebView.preferences.userStyleSheetLocation = [NSURL fileURLWithPath:path];
    
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

-(void)elementClicked:(NSArray *)eleId{
    //[self.testView setHidden:!self.testView.hidden];
    [self displayArchiveProgram];
    
    NSLog(@"invoke from web click");
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
