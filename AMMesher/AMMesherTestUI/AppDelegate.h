//
//  AppDelegate.h
//  AMMesherTestUI
//
//  Created by Wei Wang on 3/11/14.
//  Copyright (c) 2014 Wei Wang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMMesher.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property AMMesher* mesher;
@property (weak) IBOutlet NSTextField *etcdLeader;
@property (weak) IBOutlet NSTextField *key;
@property (weak) IBOutlet NSTextField *key_value;
@property (weak) IBOutlet NSTextField *errorMsg;

- (IBAction)getValue:(id)sender;
- (IBAction)setValue:(id)sender;

- (IBAction)getETCDLeader:(id)sender;

@end
