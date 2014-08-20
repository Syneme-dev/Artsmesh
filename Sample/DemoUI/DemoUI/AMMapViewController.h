//
//  AMMapViewController.h
//  DemoUI
//
//  Created by xujian on 6/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMTabPanelViewController.h"
#import <WebKit/WebKit.h>

#import <UIFramework/AMBlueButton.h>
#import <WebKit/WebFrameLoadDelegate.h>

@interface AMMapViewController : AMTabPanelViewController
@property (strong) IBOutlet WebView *webView;
@property (strong) IBOutlet NSTabView *tabs;
@property (strong) IBOutlet AMBlueButton *staticTab;
@property (weak) IBOutlet WebView *archiveWebView;
- (IBAction)onStaticTabClick:(id)sender;
@property (strong) IBOutlet AMBlueButton *liveTab;
- (IBAction)liveTabClick:(id)sender;

@end
