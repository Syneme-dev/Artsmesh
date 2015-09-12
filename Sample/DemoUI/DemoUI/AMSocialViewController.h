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
#import "AMFloatPanelViewController.h"

@interface AMSocialViewController : NSViewController

@property (strong) IBOutlet WebView *socialWebTab;
@property (retain) IBOutlet NSTabView *tabs;
- (IBAction)onFOAFTabClick:(id)sender;
- (IBAction)onBlogTabClick:(id)sender;
- (IBAction)onUpButtonClick:(id)sender;
- (IBAction)onBackButtonClick:(id)sender;
-(void)loadPage;
@property  float archiveScale;
@property (strong) IBOutlet NSButton *upTabButton;
@property (strong) IBOutlet NSButton *infoTabButton;
@property (strong) IBOutlet NSButton *blogTabButton;
@property (strong) IBOutlet NSButton *searchTabButton;

- (IBAction)smallerButtonClick:(id)sender;
- (IBAction)largerButtonClick:(id)sender ;

-(void) loadVideoWebPupupView:(NSString *)youtubeUrl ;

@property AMFloatPanelViewController *floatPanelViewController;
@property NSWindow *archiveFloatWindow;
@property WebView *floatWindowWebView;

@end
