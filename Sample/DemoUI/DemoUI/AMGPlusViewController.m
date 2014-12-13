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
    NSString *url= sender.mainFrameURL;
    sender.preferences.userStyleSheetEnabled = YES;
    NSString *path= [[NSBundle mainBundle] bundlePath];
    
    [sender setPreferencesIdentifier:@"newEventPanelPrefs"];
    path=[path stringByAppendingString:@"/Contents/Resources/new-event.css"];
    sender.preferences.userStyleSheetLocation = [NSURL fileURLWithPath:path];
    
    
    if ( loginURL && [url hasPrefix:loginURL]) {
        
    }
    else {
        //sender.preferences.userStyleSheetEnabled = NO;
    }
    
    if (!isLogin) {[self login:frame];}
    
}

- (void)login:(WebFrame *)frame {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *password = [defaults stringForKey:Preference_Key_StatusNet_Password];
    myUserName = [defaults stringForKey:Preference_Key_StatusNet_UserName];
    
    NSString *loginJs = [NSString stringWithFormat:@"$('#nickname').val('%@');$('#password').val('%@');$('#submit').click();", myUserName, password];
    [frame.webView stringByEvaluatingJavaScriptFromString:
     loginJs];
    isLogin = YES;
}

- (void)loadPage {
    isLogin = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    statusNetURL = [defaults stringForKey:Preference_Key_StatusNet_URL];
    myUserName = [defaults stringForKey:Preference_Key_StatusNet_UserName];
    loginURL = [NSString stringWithFormat:@"%@/main/login?fromMac=true", statusNetURL];
    infoUrl = [NSString stringWithFormat:@"%@/%@?fromMac=true", statusNetURL, myUserName];
    myBlogUrl = [NSString stringWithFormat:@"%@/%@/all?fromMac=true", statusNetURL, myUserName];
    publicBlogUrl = [NSString stringWithFormat:@"%@/blogs?fromMac=true", statusNetURL];
    //infoStatus = INFO_USER;
    //isInfoPage = YES;
    [self.gplusWebView.mainFrame loadRequest:
     [NSURLRequest requestWithURL:[NSURL URLWithString:
                                   loginURL]]];
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
