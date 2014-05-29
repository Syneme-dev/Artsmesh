//
//  AppDelegate.h
//  AMMesherTest
//
//  Created by Wei Wang on 5/25/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
- (IBAction)online:(id)sender;
- (IBAction)offline:(id)sender;
- (IBAction)stop:(id)sender;

@end
