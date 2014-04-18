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
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost/index.php"];
    [self.socialWebTab.mainFrame loadRequest:
     [NSURLRequest requestWithURL:baseURL]];

}


- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    self.socialWebTab.preferences.userStyleSheetEnabled = YES;
    NSString *path= [[NSBundle mainBundle] bundlePath];
    path=[path stringByAppendingString:@"/Contents/Resources/web.css"];
    self.socialWebTab.preferences.userStyleSheetLocation = [NSURL fileURLWithPath:path];
    
}


@end
