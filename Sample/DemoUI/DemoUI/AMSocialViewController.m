//
//  AMSocialViewController.m
//  DemoUI
//
//  Created by xujian on 4/18/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMSocialViewController.h"
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
@interface AMSocialViewController ()

@end

@implementation AMSocialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
                
            }
    return self;
}


-(void)loadPage{
    NSURL *baseURL = [NSURL URLWithString:@"http://artsmesh.io/main/login?fromMac=true"];
    [self.socialWebTab.mainFrame loadRequest:
     [NSURLRequest requestWithURL:baseURL]];

}


- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    self.socialWebTab.preferences.userStyleSheetEnabled = YES;
    NSString *path= [[NSBundle mainBundle] bundlePath];
    path=[path stringByAppendingString:@"/Contents/Resources/web.css"];
    self.socialWebTab.preferences.userStyleSheetLocation = [NSURL fileURLWithPath:path];
    [self login:frame];
}

-(void)login:(WebFrame *)frame{
          [frame.webView stringByEvaluatingJavaScriptFromString:
           @"$('#nickname').val('xujian');$('#password').val('p@ssw0rd');$('#submit').click();" ];
}


- (IBAction)onFOAFTabClick:(id)sender{
    [self.tabs selectTabViewItemWithIdentifier:@"1"];
}



- (IBAction)onBlogTabClick:(id)sender{
[self.tabs selectTabViewItemWithIdentifier:@"2"];
}

- (IBAction)onUpButtonClick:(id)sender{

}

- (IBAction)onAddFieldButtonClick:(id)sender{

}


@end
