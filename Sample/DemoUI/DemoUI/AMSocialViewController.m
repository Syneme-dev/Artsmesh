//
//  AMSocialViewController.m
//  DemoUI
//
//  Created by xujian on 4/18/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMSocialViewController.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import <UIFramework/AMButtonHandler.h>
#import <AMNotificationManager/AMNotificationManager.h>
#import "AMFloatPanelViewController.h"

typedef enum {
    INFO_USER,
    INFO_GROUP,
    INFO_BLOG
} SocialPanelState_Enum;//枚举名称

@interface AMSocialViewController () {
    Boolean isLogin;
    NSString *statusNetURL;
    NSString *myUserName;
    NSString *infoUrl;
    NSString *myBlogUrl;
    NSString *publicBlogUrl;
    SocialPanelState_Enum infoStatus;
    Boolean isInfoPage;
    NSString *loginURL;
}


@end

@implementation AMSocialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        [AMN_NOTIFICATION_MANAGER listenMessageType:self withTypeName:AMN_SHOWUSERINFO callback:@selector(onShowUserInfo:)];
        [AMN_NOTIFICATION_MANAGER listenMessageType:self withTypeName:AMN_SHOWGROUPINFO callback:@selector(onShowGroupInfo:)];
    }
    return self;
}

- (void)awakeFromNib {
    [AMButtonHandler changeTabTextColor:self.upTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.infoTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.blogTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.searchTabButton toColor:UI_Color_blue];

    [self.socialWebTab setFrameLoadDelegate:self];
    [self.socialWebTab setPolicyDelegate:self];
    [self.socialWebTab setUIDelegate:self];
//    [self.socialWebTab setWantsLayer:NO];
    
    self.archiveScale=1;
     [self createArchiveFloatWindow];
    
    _curTheme = [AMTheme sharedInstance];
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeTheme:)
                                                 name:@"AMThemeChanged"
                                               object:nil];
    
    _urlVars = @"fromMac=true";
    if (![_curTheme.themeType isEqualToString:@"dark"]) {
        _urlVars = [NSString stringWithFormat:@"fromMac=true&curTheme=%@", _curTheme.themeType];
    }
}

- (void)onShowUserInfo:(NSNotification *)notification {
    NSString* profileUrl = [[notification userInfo] objectForKey:@"ProfileUrl"];
    infoUrl = [NSString stringWithFormat:@"%@%@?%@", statusNetURL, profileUrl, _urlVars];

    NSURL *userInfoURL = [NSURL URLWithString:infoUrl];
    infoStatus = INFO_USER;
    isInfoPage = YES;
    [self.socialWebTab.mainFrame loadRequest:
            [NSURLRequest requestWithURL:userInfoURL]];

}


- (void)onShowGroupInfo:(NSNotification *)notification {
    NSString *groupName = [[notification userInfo] objectForKey:@"GroupName"];
    infoUrl = [NSString stringWithFormat:@"%@/group/%@?%@", statusNetURL, groupName, _urlVars];
    infoStatus = INFO_GROUP;
    isInfoPage = YES;
    NSURL *groupInfoURL = [NSURL URLWithString:infoUrl];
    [self.socialWebTab.mainFrame loadRequest:
            [NSURLRequest requestWithURL:groupInfoURL]];
}


- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id <WebPolicyDecisionListener>)listener {
    if ([sender isEqual:self.socialWebTab]) {
        [listener use];
    }
    else {
        [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
        [listener ignore];

    }
}

- (void)dealloc {
    //To avoid a error when closing
    [AMN_NOTIFICATION_MANAGER unlistenMessageType:self];
    [self.socialWebTab.mainFrame stopLoading];
    
    [self.socialWebTab setFrameLoadDelegate:nil];
    [self.socialWebTab setPolicyDelegate:nil];
    [self.socialWebTab setUIDelegate:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)webViewClose:(WebView *)sender {
    [self.socialWebTab.mainFrame stopLoading];
    [self.socialWebTab cancelOperation:nil];

    //[super webViewClose:sender];
    [sender close];
}

//Note:working for enable to open external link with new web browser.
- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id <WebPolicyDecisionListener>)listener {
    [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
    [listener ignore];
}

- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id < WebOpenPanelResultListener >)resultListener
{
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:NO];
    
    if ( [openDlg runModal] == NSOKButton )
    {
        NSArray* files = [[openDlg URLs]valueForKey:@"relativePath"];
        [resultListener chooseFilenames:files];
    }
    
}


- (void)loadPage {
    isLogin = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    statusNetURL = [defaults stringForKey:Preference_Key_StatusNet_URL];
    myUserName = [defaults stringForKey:Preference_Key_StatusNet_UserName];
    loginURL = [NSString stringWithFormat:@"%@/main/login?%@", statusNetURL, _urlVars];
    infoUrl = [NSString stringWithFormat:@"%@/%@?%@", statusNetURL, myUserName, _urlVars];
    myBlogUrl = [NSString stringWithFormat:@"%@/%@/all?%@", statusNetURL, myUserName, _urlVars];
    publicBlogUrl = [NSString stringWithFormat:@"%@/blogs?%@", statusNetURL, _urlVars];
    infoStatus = INFO_USER;
    isInfoPage = YES;
    
    if ([myUserName length] > 0) {
        //Username provided, try logging in
        [self.socialWebTab.mainFrame loadRequest:
         [NSURLRequest requestWithURL:[NSURL URLWithString:
                                       loginURL]]];
    } else {
        //Username not given, take to front page
        [self.socialWebTab.mainFrame loadRequest:
         [NSURLRequest requestWithURL:[NSURL URLWithString:
                                       statusNetURL]]];
    }
}

- (void)gotoUsersPage {
    NSURL *baseURL =
            [NSURL URLWithString:
                    [NSString stringWithFormat:@"%@/directory/users?%@", statusNetURL, _urlVars]];
    [self.socialWebTab.mainFrame loadRequest:
            [NSURLRequest requestWithURL:baseURL]];
}

- (void)gotoGroupsPage {
    NSURL *baseURL =
            [NSURL URLWithString:
                    [NSString stringWithFormat:@"%@/groups?%@", statusNetURL, _urlVars]];
    [self.socialWebTab.mainFrame loadRequest:
            [NSURLRequest requestWithURL:baseURL]];
}




/*!
 @method webView:didReceiveIcon:forFrame:
 @abstract Notifies the delegate that a page icon image for a frame has been received
 @param webView The WebView sending the message
 @param image The icon image. Also known as a "favicon".
 @param frame The frame for which a page icon has been received
 */


//- (void)webView:(WebView *)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(WebFrame *)frame{
//    NSString *moveSearchJs = @"$('#site_nav_global_primary').insertBefore('#site_nav_local_views')";
//    [self.socialWebTab stringByEvaluatingJavaScriptFromString:
//     moveSearchJs];
//}


- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    id win = [self.socialWebTab windowScriptObject];
    [win setValue:self forKey:@"socialViewController"];
    

       //NSString *url = sender.mainFrameURL;

    WebPreferences *socialTabPrefs = [self.socialWebTab preferences];
    
    socialTabPrefs.userStyleSheetEnabled = YES;
    NSString *path = [[NSBundle mainBundle] bundlePath];

    if ([_curTheme.themeType isEqualToString:@"light"]) {
        path = [path stringByAppendingString:@"/Contents/Resources/theme-light-webview.css"];
    } else {
        path = [path stringByAppendingString:@"/Contents/Resources/web.css"];
    }
    
    socialTabPrefs.userStyleSheetLocation = [NSURL fileURLWithPath:path];

    
    // Add custom css according to current theme we're using.
    NSString *cssString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSString *javascriptString = @"var style = document.createElement('style'); style.innerHTML = '%@'; document.head.appendChild(style)"; // 2 
    NSString *javascriptWithCSSString = [NSString stringWithFormat:javascriptString, cssString]; // 3
    [self.socialWebTab stringByEvaluatingJavaScriptFromString:javascriptWithCSSString]; // 4
    
    //NSLog(@"%@", javascriptWithCSSString);
    NSLog(@"%@", [self.socialWebTab stringByEvaluatingJavaScriptFromString:javascriptWithCSSString]);

     
    if (!isLogin) {[self login:frame];}
}


- (void)login:(WebFrame *)frame {
    NSLog(@"login now..");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *password = [defaults stringForKey:Preference_Key_StatusNet_Password];
    NSString *loginJs = [NSString stringWithFormat:@"$('#nickname').val('%@');$('#password').val('%@');$('#submit').click();", myUserName, password];
    [frame.webView stringByEvaluatingJavaScriptFromString:
            loginJs];
    
    isLogin = YES;
}


- (IBAction)onFOAFTabClick:(id)sender {
    NSURL *baseURL =
            [NSURL URLWithString:infoUrl];
    isInfoPage = YES;
    [self.socialWebTab.mainFrame loadRequest:
            [NSURLRequest requestWithURL:baseURL]];
    NSRange range = [infoUrl rangeOfString:@"group"];
    if (range.length == 0) {
        infoStatus = INFO_USER;
    }
    else {
        infoStatus = INFO_GROUP;
    }
}

- (IBAction)smallerButtonClick:(id)sender {
    if(self.archiveScale>0.1f){
        self.archiveScale-=0.1f;}
//self.socialWebTab.zone
     [[[[[self.socialWebTab mainFrame] frameView] documentView] superview] scaleUnitSquareToSize:NSMakeSize(0.9f, 0.9f)];
//    [self.socialWebTab makeTextSmaller:nil];
//    if(self.archiveScale<0.5f){
//        return;
//    }
//    self.archiveScale-=0.1f;
//    NSString *scriptString=[NSString stringWithFormat:@"document.documentElement.style.zoom = \"%f\";$('#circle')[0].contentDocument.documentElement.style.zoom = \"%f\";",self.archiveScale,self.archiveScale ];
//    [self.socialWebTab stringByEvaluatingJavaScriptFromString:scriptString];
}
- (IBAction)largerButtonClick:(id)sender {
//    if(self.archiveScale>0.1f){
    self.archiveScale+=0.1f;
//    }
    
    [[[[[self.socialWebTab mainFrame] frameView] documentView] superview] scaleUnitSquareToSize:NSMakeSize(1.1f, 1.1f)];
//    [self.socialWebTab makeTextLarger:nil];
//    self.archiveScale+=0.1f;
//     NSString *scriptString=[NSString stringWithFormat:@"document.documentElement.style.zoom = \"%f\";$('#circle')[0].contentDocument.documentElement.style.zoom = \"%f\";",self.archiveScale,self.archiveScale ];
//    [self.socialWebTab stringByEvaluatingJavaScriptFromString:scriptString];
}


- (IBAction)onBlogTabClick:(id)sender {
    isInfoPage = false;
    NSString *urlString = myBlogUrl;
    if (infoStatus == INFO_USER || infoStatus == INFO_GROUP) {
        urlString = infoUrl;
    }
    infoStatus = INFO_BLOG;
    NSURL *baseURL = [NSURL URLWithString:urlString];
    [self.socialWebTab.mainFrame loadRequest:
            [NSURLRequest requestWithURL:baseURL]];
}

- (IBAction)onUpButtonClick:(id)sender {
    isInfoPage = NO;
    if (infoStatus == INFO_USER) {
        [self gotoUsersPage];
    }
    else if (infoStatus == INFO_GROUP) {
        [self gotoGroupsPage];
    }
    else if (infoStatus == INFO_BLOG) {
        NSURL *baseURL = [NSURL URLWithString:publicBlogUrl];
        [self.socialWebTab.mainFrame loadRequest:
                [NSURLRequest requestWithURL:baseURL]];
    }


}

- (IBAction)onBackButtonClick:(id)sender {
    [self.socialWebTab goBack:nil];
//    [self.socialWebTab makeTextLarger:nil];
}

/// Full screen pop up video.
///

#define UI_Text_Color_Gray [NSColor colorWithCalibratedRed:(152/255.0f) green:(152/255.0f) blue:(152/255.0f) alpha:1]

-(void)createArchiveFloatWindow {
    
    //Create float panel controller + view
    AMFloatPanelViewController *fpc = [[AMFloatPanelViewController alloc] initWithNibName:@"AMFloatPanelView" bundle:nil andSize:NSMakeSize(400, 300) andTitle:@"ARCHIVE" andTitleColor:UI_Text_Color_Gray];
    _floatPanelViewController = fpc;
    
    _archiveFloatWindow = fpc.containerWindow;
    _archiveFloatWindow.level = NSFloatingWindowLevel;
    //using the code here to have a preview the part.
    //[self showVideoPopUp:@"https://www.youtube.com/embed/0JjfyOZemxk" ];
    //TODO: using the following  js code to show url.
    //sample Code:
    //socialViewController.showVideoPopUp_('https://www.youtube.com/embed/0JjfyOZemxk')

    
}

-(void) showVideoPopUp:(NSString *)youtubeUrl{
        [_floatPanelViewController setFloatPanelTitle:@"EVENT VIDEO"];
    
        [_floatPanelViewController.panelContent setSubviews: [NSArray array]];
        [self loadVideoWebPupupView:youtubeUrl];
        [_archiveFloatWindow setBackgroundColor:[NSColor blueColor]];
        [_archiveFloatWindow makeKeyAndOrderFront:NSApp];
}

-(void) loadVideoWebPupupView:(NSString *)youtubeUrl {
    WebView *group_webview = [[WebView alloc] initWithFrame:NSMakeRect(0, 16, _floatPanelViewController.panelContent.frame.size.width -20, _floatPanelViewController.panelContent.frame.size.height-20)];
    [group_webview setFrameLoadDelegate:self];
    [group_webview setDrawsBackground:NO];
    _floatWindowWebView = group_webview;
    NSURL *group_url = [NSURL URLWithString:youtubeUrl];
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

+ (NSString *) webScriptNameForSelector:(SEL)sel
{
    NSString *name=@"";
    if (sel == @selector(loadVideoWebPupupView:))
        name = @"loadVideoWebPupupView";
    else if (sel == @selector(showVideoPopUp:))
        name = @"showVideoPopUp";
    
    return name;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
    if (aSelector == @selector(loadVideoWebPupupView:)) return NO;
    if (aSelector == @selector(showVideoPopUp:)) return NO;

    return YES;
}
- (void) changeTheme:(NSNotification *) notification {
    [self loadPage];
}

@end
