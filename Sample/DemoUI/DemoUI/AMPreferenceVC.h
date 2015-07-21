//
//  AMETCDPreferenceViewController.h
//  DemoUI
//
//  Created by 王 为 on 3/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMTabPanelViewController.h"

@interface AMPreferenceVC : AMTabPanelViewController
@property (retain) IBOutlet NSTabView *tabs;

@property (strong) IBOutlet NSButton *generalTabBtn;
@property (strong) IBOutlet NSButton *jackTabBtn;
@property (strong) IBOutlet NSButton *jacktripTabBtn;
@property (strong) IBOutlet NSButton *googleTabBtn;


@property (weak) IBOutlet NSButton *oscGroupTabBtn;
@property (strong) IBOutlet NSButton *statusnetTabButton;


@end
