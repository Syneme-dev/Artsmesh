//
//  AMGPlusViewController.m
//  DemoUI
//
//  Created by Wei Wang on 8/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGPlusViewController.h"
#import "UIFramework/AMButtonHandler.h"
#import "AMCoreData/AMCoreData.h"
#import "AMPreferenceManager/AMPreferenceManager.h"

@interface AMGPlusViewController ()
@property (weak) IBOutlet NSButton *cancelBtn;
@property (weak) IBOutlet NSButton *goBtn;

@end

@implementation AMGPlusViewController
{
    NSString* statusNetEventURLString;
    Boolean isLogin;
    NSString *statusNetURL;
    NSString *myUserName;
    NSString *infoUrl;
    NSString *myBlogUrl;
    NSString *publicBlogUrl;
    Boolean isInfoPage;
    NSString *loginURL;
    NSString *eventURL;
    NSString *broadcastURL;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
    [AMButtonHandler changeTabTextColor:self.cancelBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.goBtn toColor:UI_Color_blue];
    
    
    // Load in the event webview
    [self.gplusWebView setFrameLoadDelegate:self];
    [self.gplusWebView setPolicyDelegate:self];
    [self.gplusWebView setUIDelegate:self];
    [self.gplusWebView setDrawsBackground:NO];
    
    [self loadPage];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    NSString *script = @"document.getElementById('video-url').value";
    NSString *output = [self.gplusWebView stringByEvaluatingJavaScriptFromString:script];
    
    if ( [output length] > 0 && ![output isEqualToString:broadcastURL]) {
        broadcastURL = output;
        NSLog(@"video id is: %@", broadcastURL);
    }
    
}


- (void)loadPage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    statusNetURL = [defaults stringForKey:Preference_Key_StatusNet_URL];
    eventURL = [NSString stringWithFormat:@"%@/app/event/index.php?fromMac=true", statusNetURL];
    
    [self.gplusWebView.mainFrame loadRequest:
     [NSURLRequest requestWithURL:[NSURL URLWithString:
                                   eventURL]]];
}

- (void)dealloc {
    //To avoid a error when closing
    //[AMN_NOTIFICATION_MANAGER unlistenMessageType:self];
    [self.gplusWebView.mainFrame stopLoading];
    [self.gplusWebView setFrameLoadDelegate:nil];
    [self.gplusWebView setPolicyDelegate:nil];
    [self.gplusWebView setUIDelegate:nil];
}


- (void)webViewClose:(WebView *)sender {
    [self.gplusWebView.mainFrame stopLoading];
    [self.gplusWebView cancelOperation:nil];
    
    [super webViewClose:sender];
}

@end
