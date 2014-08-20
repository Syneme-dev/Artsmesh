//
//  AMMapViewController.m
//  DemoUI
//
//  Created by xujian on 6/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMMapViewController.h"

#import <Cocoa/Cocoa.h>

#import "AMPreferenceManager/AMPreferenceManager.h"
#import <WebKit/WebKit.h>
#import <UIFramework/AMButtonHandler.h>

@interface AMMapViewController ()
{
    NSString* statusNetURLString;
}

@end

@implementation AMMapViewController

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
    [self.webView setFrameLoadDelegate:self];
    [self.webView setPolicyDelegate:self];
    [self.webView setUIDelegate:self];
    [self.webView setDrawsBackground:NO];
    [self loadPage];
    [self loadArchivePage];
}

-(void)registerTabButtons{
    super.tabs=self.tabs;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.liveTab];
    [self.tabButtons addObject:self.staticTab];
    self.showingTabsCount=2;
    
}



- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    if( [sender isEqual:self.webView] ) {
        [listener use];
    }
    else {
        [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
        [listener ignore];
        
    }
}
-(void)dealloc{
    //To avoid a error when closing
    [self.webView.mainFrame stopLoading];
}


-(void)webViewClose:(WebView *)sender
{
    [self.webView.mainFrame stopLoading];
    [self.webView cancelOperation:nil];
    [super webViewClose:sender];
}

//Note:working for enable to open external link with new web browser.
- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener {
    [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
    [listener ignore];
}


-(void)loadPage{
    //TODO:there is an errror when load social and map at the same time.
    //Error:There was a problem with your session token.
    //TODO:the social panel may change the map panel css style .
    
//    isLogin=false;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    statusNetURLString= [defaults stringForKey:Preference_Key_StatusNet_URL];
    NSURL *mapURL = [NSURL URLWithString:
                       [NSString stringWithFormat:@"%@?fromMac=true",statusNetURLString ]];
    [self.webView.mainFrame loadRequest:
    [NSURLRequest requestWithURL:mapURL]];
}

- (void)loadArchivePage
{
    NSURL *url = [NSURL URLWithString:@"http://artsmesh.io/circle/circle.html"];
    [self.archiveWebView.mainFrame loadRequest:[NSURLRequest requestWithURL:url]];
    [self.archiveWebView.mainFrame.frameView.documentView scaleUnitSquareToSize:NSMakeSize(0.8, 0.8)];
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
    self.webView.preferences.userStyleSheetEnabled = YES;
    NSString *path= [[NSBundle mainBundle] bundlePath];
   if([url hasPrefix:statusNetURLString]){
        path=[path stringByAppendingString:@"/Contents/Resources/map.css"];
    }
    else{
        self.webView.preferences.userStyleSheetEnabled = NO;
    }
    self.webView.preferences.userStyleSheetLocation = [NSURL fileURLWithPath:path];
    
}

- (IBAction)onStaticTabClick:(id)sender {
    [self.tabs selectTabViewItemAtIndex:1];

}
- (IBAction)liveTabClick:(id)sender {
    [self.tabs selectTabViewItemAtIndex:0];
}
@end
