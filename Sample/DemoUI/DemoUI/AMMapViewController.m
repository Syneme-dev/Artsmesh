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


@interface AMMapViewController ()
{
    NSString* statusNetURLString;
    NSString* statusNetProfileURLString;
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
                     [NSString stringWithFormat:@"%@?fromMac=true",statusNetURLString ]];
    [self.archiveWebView.mainFrame loadRequest:
    [NSURLRequest requestWithURL:mapURL]];
    
    [self createArchiveFloatWindow];
}

-(void)createArchiveFloatWindow {
    //display test float panel
    
    //Create float panel controller + view
    AMFloatPanelViewController *fpc = [[AMFloatPanelViewController alloc] initWithNibName:@"AMFloatPanelView" bundle:nil andSize:NSMakeSize(600, 300) andTitle:@"ARCHIVE"];
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
    
    //[_floatPanelViewController.panelContent addSubview:[self embedYouTube:@"https://www.youtube.com/embed/gm9a28J67E4" frame:NSMakeRect(0, 0, _floatPanelViewController.panelContent.frame.size.width, _floatPanelViewController.panelContent.frame.size.height)]];
    
    [self loadProfileWebView];
    
    [_archiveFloatWindow setBackgroundColor:[NSColor blueColor]];
    [_archiveFloatWindow makeKeyAndOrderFront:NSApp];
}

-(void) loadProfileWebView {
    WebView *profile_webview = [[WebView alloc] initWithFrame:NSMakeRect(0, 16, _floatPanelViewController.panelContent.frame.size.width -20, _floatPanelViewController.panelContent.frame.size.height-20)];
    
    [profile_webview setDrawsBackground:NO];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    statusNetProfileURLString = [defaults stringForKey:Preference_Key_StatusNet_URL];
    NSURL *profile_url = [NSURL URLWithString:
                          [NSString stringWithFormat:@"%@/ken?fromMac=true",statusNetURLString ]];
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
//    NSURL *baseURL =
//    [NSURL URLWithString:
//     [NSString stringWithFormat:@"%@/directory/users?fromMac=true",statusNetURL ]];
//    [self.socialWebTab.mainFrame loadRequest:
//     [NSURLRequest requestWithURL:baseURL]];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    NSLog(@"webview finished loading frame");
    NSString *url= sender.mainFrameURL;
    self.archiveWebView.preferences.userStyleSheetEnabled = YES;
    NSString *path= [[NSBundle mainBundle] bundlePath];
   if([url hasPrefix:statusNetURLString]){
        path=[path stringByAppendingString:@"/Contents/Resources/map.css"];
    }
   else if([url hasPrefix:statusNetProfileURLString]) {
        path=[path stringByAppendingString:@"/Contents/Resources/web.css"];
   }
    else{
        self.archiveWebView.preferences.userStyleSheetEnabled = NO;
    }
    
    [[self.archiveWebView windowScriptObject] setValue:self forKey:@"objcConnector"];
//    [[self.archiveWebView windowScriptObject] setValue:[NSWebScriptBridge getWebScriptBridge] forKey:@"yourBridge"];
    
    self.archiveWebView.preferences.userStyleSheetLocation = [NSURL fileURLWithPath:path];
    
}



//- (BOOL)webView:(UIWebView *)webView2
//shouldStartLoadWithRequest:(NSURLRequest *)request
// navigationType:(UIWebViewNavigationType)navigationType {
//    
//    NSString *requestString = [[request URL] absoluteString];
//    NSArray *components = [requestString componentsSeparatedByString:@":"];
//    
//    if ([components count] > 1 &&
//        [(NSString *)[components objectAtIndex:0] isEqualToString:@"myapp"]) {
//        if([(NSString *)[components objectAtIndex:1] isEqualToString:@"myfunction"])
//        {
//            
//            NSLog([components objectAtIndex:2]); [[Airship shared] displayStoreFront]; //<- This is the code to open the Store
//            NSLog([components objectAtIndex:3]); // param2
//            // Call your method in Objective-C method using the above...
//        }
//        return NO;
//    }
//    
//    return YES; // Return YES to make sure regular navigation works as expected.
//}


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
    NSLog (groupName);
}

-(void)elementClicked:(NSString *)userName{
    [self displayArchiveProgram];
    
    //Create content view that will appear inside window
    NSTextView *testContent = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
    
    [testContent setString:@"Here's some content"];
    
    //Create float panel controller + view
    AMFloatPanelViewController *fpc = [[AMFloatPanelViewController alloc] initWithNibName:@"AMFloatPanelView" bundle:nil];
    AMFloatPanelViewController *_floatPanelViewController = fpc;
    _floatPanelViewController.panelTitle = @"Test Window";
    AMFloatPanelView *floatPanel = (AMFloatPanelView *) fpc.view;
    
    [fpc.panelContent addSubview:testContent];
    
    //Create window to hold everything
    NSRect frame = NSMakeRect(self.view.frame.size.width/2, self.view.frame.size.height/2, testContent.frame.size.width, (testContent.frame.size.height + 41) + floatPanel.borderThickness);
    NSWindow *_testWindow  = [[NSWindow alloc] initWithContentRect:frame
                                               styleMask:NSBorderlessWindowMask
                                                 backing:NSBackingStoreBuffered
                                                   defer:NO];
    fpc.containerWindow = _testWindow;
    _testWindow.hasShadow = YES;
    [_testWindow.contentView addSubview:floatPanel];
    
    [_testWindow.contentView setAutoresizesSubviews:YES];
    [testContent setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    // Add sizing constraints to window
    _floatPanelViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subView]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:@{@"subView" : _floatPanelViewController.view}];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"subView" : _floatPanelViewController.view}];
    [_testWindow.contentView addConstraints:verticalConstraints];
    [_testWindow.contentView addConstraints:horizontalConstraints];
    
    [_testWindow.contentView setAutoresizesSubviews:YES];
    [_floatPanelViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    // Display test Window
    [_testWindow setBackgroundColor:[NSColor blueColor]];
    [_testWindow makeKeyAndOrderFront:self];
    
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
