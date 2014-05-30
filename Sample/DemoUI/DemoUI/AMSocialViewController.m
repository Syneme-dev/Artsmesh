//
//  AMSocialViewController.m
//  DemoUI
//
//  Created by xujian on 4/18/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMSocialViewController.h"
#import <Cocoa/Cocoa.h>

#import "AMPreferenceManager/AMPreferenceManager.h"
#import <WebKit/WebKit.h>
@interface AMSocialViewController ()
{
    Boolean isLogin;
    NSString* statusNetURL;
    NSString* username;
    NSString* infoUrl;
    NSString* myBlogUrl;
}


@end

@implementation AMSocialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
        
            }
    return self;
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    if( [sender isEqual:self.socialWebTab] ) {
        [listener use];
    }
    else {
        [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
        [listener ignore];

    }
}


- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener {
    [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
    [listener ignore];
}


-(void)loadPage{
    isLogin=false;
     NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
     statusNetURL= [defaults stringForKey:Preference_Key_StatusNet_URL];
   username = [defaults stringForKey:Preference_Key_StatusNet_UserName];
    NSURL *loginURL = [NSURL URLWithString:
                      [NSString stringWithFormat:@"%@/main/login?fromMac=true",statusNetURL ]];
    
    infoUrl=        [NSString stringWithFormat:@"%@/%@?fromMac=true",statusNetURL,username ];
    
    myBlogUrl =[NSString stringWithFormat:@"%@/%@/all?fromMac=true",statusNetURL,username ];
    [self.socialWebTab.mainFrame loadRequest:
     [NSURLRequest requestWithURL:loginURL]];
}

-(void)gotoUsersPage{
    NSURL *baseURL =
    [NSURL URLWithString:
     [NSString stringWithFormat:@"%@/directory/users?fromMac=true",statusNetURL ]];
    [self.socialWebTab.mainFrame loadRequest:
     [NSURLRequest requestWithURL:baseURL]];
}

-(void)gotoGroupsPage{
    NSURL *baseURL =
    [NSURL URLWithString:
     [NSString stringWithFormat:@"%@/groups?fromMac=true",statusNetURL ]];
    [self.socialWebTab.mainFrame loadRequest:
     [NSURLRequest requestWithURL:baseURL]];
}


- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    NSString *url= sender.mainFrameURL;
    self.socialWebTab.preferences.userStyleSheetEnabled = YES;
    NSString *path= [[NSBundle mainBundle] bundlePath];
   
    if([url isEqual:infoUrl])
    {
        path=[path stringByAppendingString:@"/Contents/Resources/info.css"];
    }
    else if([url hasPrefix:statusNetURL]){
        path=[path stringByAppendingString:@"/Contents/Resources/web.css"];
    }
             else{
                 self.socialWebTab.preferences.userStyleSheetEnabled = NO;
             }
    self.socialWebTab.preferences.userStyleSheetLocation = [NSURL fileURLWithPath:path];

    if(!isLogin)
    {    [self login:frame];}
}

-(void)login:(WebFrame *)frame{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* password = [defaults stringForKey:Preference_Key_StatusNet_Password];
    NSString *loginJs=[NSString stringWithFormat:@"$('#nickname').val('%@');$('#password').val('%@');$('#submit').click();",username,password ];
          [frame.webView stringByEvaluatingJavaScriptFromString:
           loginJs];
    isLogin=TRUE;
}


- (IBAction)onFOAFTabClick:(id)sender{
    NSURL *baseURL =
    [NSURL URLWithString:infoUrl];
    [self.socialWebTab.mainFrame loadRequest:
    [NSURLRequest requestWithURL:baseURL]];
}



- (IBAction)onBlogTabClick:(id)sender{
    NSURL *baseURL=[NSURL URLWithString:myBlogUrl];
    [self.socialWebTab.mainFrame loadRequest:
     [NSURLRequest requestWithURL:baseURL]];

}

- (IBAction)onUpButtonClick:(id)sender{
     NSString *url= self.socialWebTab.mainFrameURL;
    if([url isEqual:infoUrl])
    {
     [self gotoUsersPage];
    }
    else if([url isEqual:myBlogUrl]){
        NSURL *baseURL=[NSURL URLWithString:statusNetURL];
        [self.socialWebTab.mainFrame loadRequest:
         [NSURLRequest requestWithURL:baseURL]];
    
    }
}

- (IBAction)onAddFieldButtonClick:(id)sender{
     [self gotoGroupsPage];

}


@end
