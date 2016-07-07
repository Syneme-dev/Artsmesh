//
//  AMPanelControlBarViewController.h
//  DemoUI
//
//  Created by xujian on 7/23/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMPanelControlBarViewController : NSViewController
@property IBOutlet NSButton *userBtn;
@property IBOutlet NSButton *groupBtn;
@property IBOutlet NSButton *chatBtn;
@property IBOutlet NSButton *socialBtn;
@property IBOutlet NSButton *mapBtn;
@property IBOutlet NSButton *visualBtn;
@property IBOutlet NSButton *mixingBtn;
@property IBOutlet NSButton *musicScoreBtn;
@property IBOutlet NSButton *clockBtn;
@property IBOutlet NSButton *oscBtn;
@property IBOutlet NSButton *terminalBtn;
@property IBOutlet NSButton *settingBtn;
@property IBOutlet NSButton *radioBtn;
@property IBOutlet NSButton *questionBtn;

- (IBAction)onSidebarItemClick:(NSButton *)sender ;


- (IBAction)onSidebarDoubleClick:(NSButton *)sender ;
@end
