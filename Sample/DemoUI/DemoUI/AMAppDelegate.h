//
//  AMAppDelegate.h
//  DemoUI
//
//  Created by Sky JIA on 1/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define AM_APPDELEGATE (AMAppDelegate*)[NSApp delegate]
@interface AMAppDelegate : NSObject <NSApplicationDelegate,AMPluginAppDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *mesherName;
- (IBAction)mesh:(id)sender;
@property (weak) IBOutlet NSButton *mesherButton;

@end
