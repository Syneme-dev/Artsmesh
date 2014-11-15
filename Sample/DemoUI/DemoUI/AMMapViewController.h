//
//  AMMapViewController.h
//  DemoUI
//
//  Created by xujian on 6/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMTabPanelViewController.h"
#import "AMLiveMapView.h"
#import <WebKit/WebKit.h>

#import <UIFramework/AMBlueButton.h>
#import <WebKit/WebFrameLoadDelegate.h>

@interface AMMapViewController : AMTabPanelViewController

@property (strong) IBOutlet NSTabView *tabs;
@property (strong) IBOutlet NSButton *staticTab;
@property (weak) IBOutlet WebView *archiveWebView;
@property (strong) IBOutlet AMLiveMapView *liveMapView;
- (IBAction)onStaticTabClick:(id)sender;
@property (strong) IBOutlet NSButton *liveTab;
- (IBAction)liveTabClick:(id)sender;
@property  float archiveScale;

@end
