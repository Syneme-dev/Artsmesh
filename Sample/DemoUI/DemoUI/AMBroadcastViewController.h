//
//  AMGPlusViewController.h
//  DemoUI
//
//  Created by Wei Wang on 8/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "AMTabPanelViewController.h"
#import "GTMOAuth2WindowController.h"

@interface AMBroadcastViewController : AMTabPanelViewController

@property (strong) IBOutlet NSButton *settingsBtn;

@property (strong) IBOutlet NSButton *youtubeBtn;

@property (weak) IBOutlet WebView *gplusWebView;

@property (strong) IBOutlet NSTabView *groupTabView;

- (void)changeBroadcastURL : (NSString *)newURL;
- (IBAction)youtubeBtnClick:(id)sender;
- (IBAction)settingsBtnClick:(id)sender;

@end
