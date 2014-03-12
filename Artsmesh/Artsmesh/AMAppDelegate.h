//
//  AMAppDelegate.h
//  Artsmesh
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Sky JIA. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *mesherName;

@end
