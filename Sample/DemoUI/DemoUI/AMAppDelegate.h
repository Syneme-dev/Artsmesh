//
//  AMAppDelegate.h
//  DemoUI
//
//  Created by Sky JIA on 1/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMMainWindowController.h"

#define AM_APPDELEGATE (AMAppDelegate*)[NSApp delegate]

@interface AMAppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet AMMainWindowController *mainWindowController;

@end
