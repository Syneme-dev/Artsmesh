//
//  AMPanelControlBarViewController.h
//  DemoUI
//
//  Created by xujian on 7/23/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMControlBarButtonResponder.h"
#import "UIFramework/AMTheme.h"

@interface AMPanelControlBarViewController : NSViewController

@property (strong) IBOutlet AMControlBarButtonResponder *panelHelpBtn;
@property AMTheme *curTheme;

- (IBAction)onSidebarItemClick:(NSButton *)sender ;


- (IBAction)onSidebarDoubleClick:(NSButton *)sender ;
@end
