//
//  AMGPlusViewController.h
//  DemoUI
//
//  Created by Wei Wang on 8/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "GTMOAuth2WindowController.h"

@interface AMBroadcastViewController : NSViewController

@property (weak) IBOutlet WebView *gplusWebView;

- (void)changeBroadcastURL : (NSString *)newURL;

@end
