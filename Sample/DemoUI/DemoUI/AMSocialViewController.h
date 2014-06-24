//
//  AMSocialViewController.h
//  DemoUI
//
//  Created by xujian on 4/18/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <WebKit/WebFrameLoadDelegate.h>

@interface AMSocialViewController : NSViewController

@property (strong) IBOutlet WebView *socialWebTab;
@property (retain) IBOutlet NSTabView *tabs;
- (IBAction)onFOAFTabClick:(id)sender;
- (IBAction)onBlogTabClick:(id)sender;
- (IBAction)onUpButtonClick:(id)sender;
- (IBAction)onAddFieldButtonClick:(id)sender;
-(void)loadPage;

@end
