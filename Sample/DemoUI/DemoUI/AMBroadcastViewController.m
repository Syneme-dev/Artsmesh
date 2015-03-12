//
//  AMGPlusViewController.m
//  DemoUI
//
//  Created by Wei Wang on 8/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMBroadcastViewController.h"
#import "UIFramework/AMButtonHandler.h"
#import "AMCoreData/AMCoreData.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMMesher/AMMesher.h"

@interface AMBroadcastViewController ()
@property (weak) IBOutlet NSButton *cancelBtn;
@property (weak) IBOutlet NSButton *goBtn;

@end

@implementation AMBroadcastViewController
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
    
    NSString *scope;
    NSString *kMyClientID;
    NSString *kMylientSecret;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupChanged:) name:AM_LIVE_GROUP_CHANDED object:nil];
    
    [AMButtonHandler changeTabTextColor:self.cancelBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.goBtn toColor:UI_Color_blue];
    
    
    // Load in the event webview
    
    [self.gplusWebView setFrameLoadDelegate:self];
    [self.gplusWebView setPolicyDelegate:self];
    [self.gplusWebView setUIDelegate:self];
    [self.gplusWebView setDrawsBackground:NO];
    
    [self loadPage];
    
    [self testOAuth];
}

- (void)testOAuth {
    NSApplication *myApp = [NSApplication sharedApplication];
    NSWindow *curWindow = [myApp keyWindow];
    
    scope = @"https://www.googleapis.com/auth/youtube";
    kMyClientID = @"998042950112-nf0sggo2f56tvt8bcord9kn0qe528mqv.apps.googleusercontent.com";
    kMylientSecret = @"P1QKHOBVo-1RTzpz9sOde4JP";
    
    GTMOAuth2WindowController *windowController;
    windowController = [[GTMOAuth2WindowController alloc] initWithScope:scope
                                                               clientID:kMyClientID
                                                           clientSecret:kMylientSecret
                                                       keychainItemName:nil
                                                         resourceBundle:nil];
    
    [windowController signInSheetModalForWindow:curWindow
                                       delegate:self
                               finishedSelector:@selector(windowController:finishedWithAuth:error:)];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    NSString *script = @"document.getElementById('video-url').value";
    NSString *output = [self.gplusWebView stringByEvaluatingJavaScriptFromString:script];
    
    if ( [output length] > 0 && ![output isEqualToString:broadcastURL]) {
        broadcastURL = output;
        
        [self changeBroadcastURL:broadcastURL];
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

- (void)changeBroadcastURL : (NSString *)newURL {
    NSUserDefaults *defaults = [AMPreferenceManager standardUserDefaults];
    
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    if ([group.broadcastingURL isEqualToString:newURL]) {
        return;
    }
    
    if ([newURL isEqualToString:@""]) {
        newURL = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Key_Cluster_BroadcastURL];
    }
    
    group.broadcastingURL= newURL;
    
    //if (group.broadcasting) {
    [[AMMesher sharedAMMesher] updateGroup];
    //}
    [defaults setObject:group.broadcastingURL forKey:Preference_Key_Cluster_BroadcastURL];
    //[defaults synchronize];
    
}

-(void)groupChanged:(NSNotification *)notification
{
    /**
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    NSLog(@"Group changed! New broadcastURL is: %@", group.broadcastingURL);
    
    NSUserDefaults *defaults = [AMPreferenceManager standardUserDefaults];
    NSLog(@"broadcast url default prefs is: %@", [defaults objectForKey:Preference_Key_Cluster_BroadcastURL]);
     **/
    
}


- (void)dealloc {
    //To avoid a error when closing
    //[AMN_NOTIFICATION_MANAGER unlistenMessageType:self];
    [self.gplusWebView.mainFrame stopLoading];
    [self.gplusWebView setFrameLoadDelegate:nil];
    [self.gplusWebView setPolicyDelegate:nil];
    [self.gplusWebView setUIDelegate:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)webViewClose:(WebView *)sender {
    [self.gplusWebView.mainFrame stopLoading];
    [self.gplusWebView cancelOperation:nil];
    
    [super webViewClose:sender];
}


- (void)windowController:(GTMOAuth2WindowController *)windowController
        finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error {
}

@end
