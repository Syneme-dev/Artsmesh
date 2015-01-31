//
//  AMUserViewController.h
//  DemoUI
//
//  Created by 王 为 on 3/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMTabPanelViewController.h"
#import "AMTextFieldView.h"
#import "UIFramework/AMFoundryFontView.h"

@interface AMUserViewController : AMTabPanelViewController

@property (strong) IBOutlet NSButton *userTabButton;
@property (strong) IBOutlet NSButton *groupTabButton;
@property (strong) IBOutlet NSButton *projectTabButton;
@property (strong) IBOutlet NSTabView *tabs;
- (IBAction)onUserTabClick:(id)sender;
- (IBAction)onGroupTabClick:(id)sender;
- (IBAction)onProjectTabClick:(id)sender;

@end
