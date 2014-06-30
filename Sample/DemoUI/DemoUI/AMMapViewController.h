//
//  AMMapViewController.h
//  DemoUI
//
//  Created by xujian on 6/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <WebKit/WebKit.h>
#import <WebKit/WebFrameLoadDelegate.h>

@interface AMMapViewController : NSViewController
@property (strong) IBOutlet WebView *webView;

@end
