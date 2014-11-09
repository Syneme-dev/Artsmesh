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

}

- (void)onShowUserInfo:(NSNotification *)notification {
    NSString *userName = [[notification userInfo] objectForKey:@"UserName"];
    infoUrl = [NSString stringWithFormat:@"%@/%@?fromMac=true", statusNetURL, userName];
    NSURL *userInfoURL = [NSURL URLWithString:infoUrl];
    infoStatus = INFO_USER;
    isInfoPage = YES;
    [self.socialWebTab.mainFrame loadRequest:
            [NSURLRequest requestWithURL:userInfoURL]];

}


- (void)onShowGroupInfo:(NSNotification *)notification {
    NSString *groupName = [[notification userInfo] objectForKey:@"GroupName"];
    infoUrl = [NSString stringWithFormat:@"%@/group/%@?fromMac=true", statusNetURL, groupName];
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
    [self.socialWebTab.mainFrame stopLoading];
}


- (void)webViewClose:(WebView *)sender {
    [self.socialWebTab.mainFrame stopLoading];
    [self.socialWebTab cancelOperation:nil];

    [super webViewClose:sender];
}

//Note:working for enable to open external link with new web browser.
- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id <WebPolicyDecisionListener>)listener {
    [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
    [listener ignore];
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
    infoStatus = INFO_USER;
    isInfoPage = YES;
    [self.socialWebTab.mainFrame loadRequest:
            [NSURLRequest requestWithURL:[NSURL URLWithString:
                    loginURL]]];
}

- (void)gotoUsersPage {
    NSURL *baseURL =
            [NSURL URLWithString:
                    [NSString stringWithFormat:@"%@/directory/users?fromMac=true", statusNetURL]];
    [self.socialWebTab.mainFrame loadRequest:
            [NSURLRequest requestWithURL:baseURL]];
}

- (void)gotoGroupsPage {
    NSURL *baseURL =
            [NSURL URLWithString:
                    [NSString stringWithFormat:@"%@/groups?fromMac=true", statusNetURL]];
    [self.socialWebTab.mainFrame loadRequest:
            [NSURLRequest requestWithURL:baseURL]];
}


- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    NSString *url = sender.mainFrameURL;

    self.socialWebTab.preferences.userStyleSheetEnabled = YES;
    NSString *path = [[NSBundle mainBundle] bundlePath];

    if (isInfoPage && ([url isEqual:loginURL] || [url isEqual:infoUrl]))
    {
        path = [path stringByAppendingString:@"/Contents/Resources/info.css"];
    }
    else if ([url hasPrefix:statusNetURL]) {
        path = [path stringByAppendingString:@"/Contents/Resources/web.css"];
    }
    else {
        self.socialWebTab.preferences.userStyleSheetEnabled = NO;
    }
    self.socialWebTab.preferences.userStyleSheetLocation = [NSURL fileURLWithPath:path];

    if (!isLogin) {[self login:frame];}
}

- (void)login:(WebFrame *)frame {
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

- (IBAction)onAddFieldButtonClick:(id)sender {
//    [self.socialWebTab makeTextLarger:nil];
}


@end
