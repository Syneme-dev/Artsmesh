//
//  AMVisualViewController.h
//  DemoUI
//
//  Created by xujian on 6/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <UIFramework/AMBlueButton.h>
#import "AMTabPanelViewController.h"

@interface AMVisualViewController : AMTabPanelViewController
- (IBAction)onVisualTabClick:(NSButton *)sender;
- (IBAction)onOSCTabClick:(id)sender;
- (IBAction)onAudioTabClick:(id)sender;
- (IBAction)onVideoTabClick:(id)sender;
@property (strong) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSButton *oscTab;
@property (strong) IBOutlet NSButton *visualTab;

@property (strong) IBOutlet NSButton *videoTab;

@property (strong) IBOutlet NSButton *audioTab;


@end
