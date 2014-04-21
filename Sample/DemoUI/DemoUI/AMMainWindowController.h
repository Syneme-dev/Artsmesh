//
//  AMMainWindowController.h
//  DemoUI
//
//  Created by xujian on 4/17/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface AMMainWindowController : NSWindowController
- (IBAction)mesh:(id)sender;
- (void)showDefaultWindow ;
@property (weak) IBOutlet NSTextField *versionLabel;

@end
